# Email Notifications Architecture — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DESIGN
**Date**: 2026-03-10
**Status**: Accepted

---

## Overview

The daily email is the user's external trigger for their practice session. It must show the exact queue the app will show — no divergence. This is enforced by the single queue builder constraint: both email and app read from the same `daily_queues` row.

The email is a developer tool digest: minimal, information-dense, no promotional content.

---

## Email Design

### Subject Line

Format: `Today's Queue — {N} review{s} + {lesson_line} (est. {T} min)`

Examples:
- `Today's Queue — 4 reviews + 1 lesson option (est. 10 min)`
- `Today's Queue — 2 reviews (est. 2 min)`
- `Today's Queue — 7 reviews + 1 lesson option (est. 15 min)`

Rules:
- Subject ≤ 100 characters (AC-009-02)
- Contains queue count and time estimate (FR-4.2)
- `lesson_line` is omitted if no new lesson is available
- Time estimate: `ceil(queue_count * 45 / 60)` minutes for reviews + 5 minutes if lesson present

### Email Body Variables

| Variable | Source | Example value |
|----------|--------|---------------|
| `{user_email}` | users.email | marcus@example.com |
| `{queue_count}` | daily_queues.exercise_ids.length | 4 |
| `{review_items}` | exercises fetched by IDs in daily_queues.exercise_ids | [Ruby Blocks, Symbols vs Strings, ...] |
| `{streak_count}` | users.streak_count | 12 |
| `{lesson_title}` | next available lesson title (nullable) | "Procs and Lambdas" |
| `{session_url}` | platform URL + session path | https://rubysyntax.fly.dev/session/start |
| `{estimated_time}` | derived from queue_count | 10 min |
| `{delivery_hour}` | users.email_delivery_hour | 8 AM |

### Email Body Template

```
Subject: Today's Queue — {queue_count} reviews + 1 lesson option (est. {estimated_time} min)

---
Ruby Syntax Practice — Day {streak_count} streak

Today's review queue ({queue_count} exercises):
  • {review_item_1.concept_name}
  • {review_item_2.concept_name}
  • {review_item_3.concept_name}
  • {review_item_4.concept_name}

[Optional lesson, if available:]
  → New lesson available: {lesson_title} (~5 min)

Start today's session: {session_url}
---

You're receiving this because you opted in to daily practice reminders.
To turn off: {opt_out_url}
```

**Template rules**:
- Plain text primary; HTML version mirrors exactly (no additional formatting)
- No images, tracking pixels, or external resources (FR-4.7)
- No "unsubscribe from marketing" language — opt-out link leads to settings page (FR-4.8)
- Opt-out URL: `{platform_url}/settings/email` — not a one-click unsubscribe endpoint (settings page shows all preferences; prevents accidental opt-out from email client preview)
- CTA link is a single URL pointing to `/session/start` (FR-4.4)
- Streak count shown (FR-4.5)

---

## Email Trigger Mechanism

### Cron Schedule

```ruby
# config/schedule.rb (Whenever gem)
every :day, at: '2:00 am' do
  runner "QueueBuilderJob.perform_later"
end
```

The cron runs at **2:00 AM UTC**. This is the queue-building job, not the email-sending job. Email sending is a separate job enqueued after queue building completes.

**Why 2:00 AM UTC**:
- User timezone is stored as `users.timezone`
- Default delivery time is 8:00 AM user-local
- Queue must be built before delivery time
- 2:00 AM UTC = 6 hours before 8:00 AM UTC; covers users in UTC through UTC+5
- For users in UTC-5 to UTC+5, 2:00 AM UTC is before their configured 8:00 AM local
- For users in UTC+6 and later (Asia), 2:00 AM UTC may be close to their morning — acceptable for single-user MVP (builder is in a known timezone)
- Post-MVP with multi-user: move to per-timezone queue building

### Job Sequence

```
02:00 AM UTC — Cron triggers QueueBuilderJob
  │
  ├─ QueueBuilderJob.perform
  │   For each opted-in user:
  │     queue = QueueBuilder.build(user_id, Date.today_in_timezone(user.timezone))
  │     DailyQueue.upsert(user_id, queue_date, exercise_ids: queue)
  │
  └─ After all queues built:
      EmailDispatchJob.perform_later(date: Date.today)

EmailDispatchJob.perform (runs immediately after queue build)
  │
  For each opted-in user:
  │   queue = DailyQueue.find_by(user_id, queue_date)
  │   next if queue.nil? || queue.exercise_ids.empty?   ← no email if empty (FR-3.4)
  │   next if queue.email_sent_at.present?              ← idempotency guard
  │
  │   delivery_time = user.local_delivery_datetime      ← 8:00 AM in user timezone
  │   DailyQueueMailer
  │     .daily_digest(user, queue)
  │     .deliver_later(wait_until: delivery_time)       ← Solid Queue scheduled delivery
  │
  │   queue.update!(email_sent_at: Time.current)        ← set before enqueue (optimistic)
  └─ Done
```

**Scheduled delivery**: `deliver_later(wait_until: delivery_time)` defers the actual Postmark API call until the user's configured delivery time. Queue is built at 2 AM; email arrives at 8 AM (or user-configured hour).

---

## Provider Selection and Configuration

### Postmark

**Adapter**: `postmark-rails` gem. Drop-in Action Mailer adapter.

```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :postmark
config.action_mailer.postmark_settings = {
  api_token: ENV["POSTMARK_API_TOKEN"]
}
```

**Configuration requirements**:
- `POSTMARK_API_TOKEN`: stored as Fly.io secret (never in source)
- `from` address: `practice@{domain}` — must be verified in Postmark sender signatures
- `message_stream`: `"outbound"` (Postmark's default transactional stream)
- No click tracking, open tracking, or unsubscribe management (prevents Postmark from injecting promotional elements — FR-4.7)

**Postmark account settings**:
- Disable link tracking: explicitly off
- Disable open tracking: explicitly off
- Message stream: "Transactional" type only

**Free tier limit**: 100 emails/month. Single user sends ≤ 31 emails/month. Well within limit. If multi-user: 1,000 emails/month on Postmark starter ($15/month) — viable at small scale.

---

## Idempotency: What Happens If the Email Job Runs Twice?

Two layers of idempotency protection:

### Layer 1: DailyQueue Upsert

```sql
INSERT INTO daily_queues (user_id, queue_date, exercise_ids)
VALUES (:user_id, :queue_date, :exercise_ids)
ON CONFLICT (user_id, queue_date)
DO UPDATE SET
  exercise_ids = EXCLUDED.exercise_ids,
  updated_at = NOW();
```

Running `QueueBuilderJob` twice produces the same `daily_queues` row. No duplicate rows possible.

### Layer 2: Email Sent Guard

```ruby
# In EmailDispatchJob
queue = DailyQueue.find_by(user_id: user.id, queue_date: Date.today)
return if queue.email_sent_at.present?   # Already sent — skip

queue.update!(email_sent_at: Time.current)  # Mark before enqueueing (optimistic lock)
DailyQueueMailer.daily_digest(user, queue).deliver_later(wait_until: delivery_time)
```

The `email_sent_at` field is set **before** the email is enqueued. If the job crashes between set and enqueue, the email is not sent (false positive guard — user misses one email). This is preferred over a false negative (duplicate email). The partial index on `email_sent_at IS NULL` makes the lookup fast.

**Race condition**: If EmailDispatchJob runs concurrently for the same user (two job workers), a database transaction with `SELECT FOR UPDATE` on the `daily_queues` row prevents both from sending. In practice, Solid Queue with a single worker process makes this unlikely; defensive lock costs nothing.

**Postmark deduplication**: Postmark does not deduplicate on its own. Our application-level guard is the primary protection.

---

## Shared Queue Builder — Email/App Consistency

This is the critical integration constraint from DISCUSS (shared-artifacts-registry: `review_queue` — HIGH risk).

**Architecture enforcement**:

```
QueueBuilder.build(user_id, date)
  → persists to daily_queues(user_id, queue_date)

Email reads:  DailyQueue.find_by(user_id, queue_date).exercise_ids
App reads:    DailyQueue.find_by(user_id, queue_date).exercise_ids
```

Both email and app read from the same database column. There is no separate email-queue-calculation path and no separate app-queue-calculation path. The `QueueBuilder` runs exactly once per user per day (idempotency prevents re-calculation).

**Session immutability** (FR-3.3): Once `SessionTracker.start` is called, the app reads the queue from `daily_queues.exercise_ids` and does not re-query `reviews`. New exercises that become due mid-session are not added. The queue is frozen at session start.

**Consistency guarantee** (AC-004-02): If Marcus receives an email listing exercises A, B, C, D and then opens the app, the app reads from the same `daily_queues` row the email read from. The order is identical. No divergence possible.

---

## Delivery Failure Handling (AC-009-05)

```
EmailDispatchJob encounters Postmark API error:
  │
  ├─ Log error: { timestamp, user_id, error_code, error_message }
  │  (No user_email in logs — privacy; user_id only)
  │
  ├─ Reset email_sent_at to NULL (allow retry)
  │
  └─ Re-enqueue: EmailRetryJob.perform_later(user_id, queue_date, wait: 15.minutes)
      │
      EmailRetryJob (runs once, 15 min later):
        ├─ Check email_sent_at IS NULL (guard)
        ├─ Attempt delivery again
        ├─ On success: set email_sent_at
        └─ On failure: log final failure; do NOT retry again (FR: retry once)
```

**User experience**: App is unaffected by email failure (AC-009-05). No error shown to user. No interruption to session or SM-2 state.

---

## Email Opt-Out Flow

Marcus can opt out at any time (FR-4.8):

1. Link in email footer: `{platform_url}/settings/email`
2. Settings page shows `email_opted_in` toggle
3. POST `/settings/email` with `email_opted_in=false` → `users.update!(email_opted_in: false)`
4. `EmailDispatchJob` checks `user.email_opted_in` before enqueueing any email
5. Opt-out does not affect SM-2 state, queue building, or app access

Opting back in re-enables delivery from the next nightly build cycle.

---

## Monitoring and Observability

| Signal | Mechanism | Alert threshold |
|--------|-----------|-----------------|
| Email delivery success | Log `email_sent_at` set | — |
| Postmark API error | Log + retry counter | Any final failure (after 1 retry) |
| Queue builder duration | Log job execution time | > 10 seconds (for single user; budget is 5s per NFR-1.5) |
| Missing queue (no daily_queue row by 3 AM) | Alert check at 3 AM | Any opted-in user with no queue row |
| Duplicate email prevention | `email_sent_at` uniqueness | Logged if guard fires |
