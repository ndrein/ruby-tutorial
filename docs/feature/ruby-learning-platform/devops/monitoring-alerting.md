# Monitoring and Alerting — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DEVOPS
**Date**: 2026-03-10
**Status**: Accepted

---

## Overview

Monitoring strategy for a single-user personal tool on Fly.io free tier. No SLA uptime guarantee, no on-call rotation, no paid monitoring services. The goal is: know when something breaks, know why, know how to fix it.

---

## Fly.io Built-in Metrics

Available in the Fly.io dashboard (https://fly.io/dashboard) at no cost:

| Metric | Description | Access |
|--------|-------------|--------|
| CPU utilization | Per-machine CPU % | Fly dashboard → App → Metrics |
| Memory usage | RAM used/available (256 MB total) | Fly dashboard → App → Metrics |
| Request count | HTTP requests/minute | Fly dashboard → App → Metrics |
| Response time | P50/P95/P99 response time | Fly dashboard → App → Metrics |
| Machine restarts | Count of machine restarts | Fly dashboard → App → Machines |
| Disk usage | Volume usage (Postgres) | Fly dashboard → Postgres app |

These metrics are viewable in the Fly.io web UI. No configuration required — they are collected automatically for all Fly Machines.

### Accessing Metrics via CLI

```bash
# Machine status and restart count
fly status --app <APP_NAME>

# Postgres machine status
fly status --app <APP_NAME>-db

# Open Fly dashboard for metrics charts
fly dashboard --app <APP_NAME>
```

---

## Alert Strategy

### Fly.io Email Alerts (Free)

Fly.io sends automatic email notifications for:
- Machine crash loops (machine exits non-zero repeatedly)
- Machine failing to start after deploy
- Health check failures causing machine to be taken out of service

These alerts go to the Fly.io account email address. No configuration required.

### Manual Alert Check

For a single-user personal tool, a daily check of `fly status` is sufficient as a routine. Add this to morning workflow:

```bash
fly status --app <APP_NAME>
# Expected: Machine state: started, health checks: passing
```

### No External Alerting Services

PagerDuty, OpsGenie, and similar on-call platforms are outside scope. Email from Fly.io for machine crashes is the sole automated alert channel.

---

## Database Monitoring

### Manual Inspection via fly postgres connect

```bash
# Open psql session to production Postgres
fly postgres connect --app <APP_NAME>-db

# Check active connections
SELECT pid, usename, application_name, state, query_start, query
FROM pg_stat_activity
WHERE datname = 'ruby_learn_production'
ORDER BY query_start DESC;

# Check table sizes
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# Check for long-running queries (> 5 seconds)
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE state != 'idle'
  AND (now() - pg_stat_activity.query_start) > interval '5 seconds';

# Check review table growth (core data)
SELECT COUNT(*) as total_reviews,
       MIN(created_at) as first_review,
       MAX(reviewed_at) as last_review
FROM reviews;
```

### Database Health Check

The `/up` health endpoint (configured in observability-design.md) verifies database connectivity on every Fly health check. If the database is unreachable, Fly marks the machine unhealthy and sends an email alert.

---

## Email Delivery Monitoring

### Postmark Dashboard

Access at https://account.postmarkapp.com → Servers → [Server Name] → Activity

Postmark free tier provides:
- Delivery confirmation per message
- Bounce tracking
- Open tracking (if enabled — keep disabled per FR-4.7 anti-tracking requirement)

### Postmark Webhooks (Free)

Configure bounce and delivery webhooks in the Postmark server settings to log delivery events. In `config/initializers/postmark.rb` or via the Postmark dashboard:

Webhook URL: `https://<APP_NAME>.fly.dev/webhooks/postmark`

Implement a simple webhook receiver:

```ruby
# config/routes.rb
post "/webhooks/postmark", to: "webhooks/postmark#create"

# app/controllers/webhooks/postmark_controller.rb
class Webhooks::PostmarkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_postmark_token

  def create
    event_type = params[:RecordType]
    recipient  = params[:Recipient]
    message_id = params[:MessageID]

    Rails.logger.info({
      event: "email_webhook",
      type: event_type,
      recipient: recipient,
      message_id: message_id,
      time: Time.current.iso8601
    }.to_json)

    head :ok
  end

  private

  def verify_postmark_token
    # Postmark signs webhook calls; verify if needed
    head :forbidden unless request.headers["X-Postmark-Token"] == ENV.fetch("POSTMARK_WEBHOOK_TOKEN", nil)
  end
end
```

This logs bounce and delivery events to stdout (captured by Fly logs) without requiring a paid monitoring service.

---

## Service Level Indicators (SLIs)

SLIs appropriate for a single-user personal tool. These are measurement points, not contractual SLOs.

### SLI-1: Exercise Submission Response Time

**Definition**: Time from POST `/exercises/:id/submit` received to response returned.
**Target**: < 500 ms (AC-005-02)
**Measurement**: Lograge `duration` field in request logs.
**How to check**:
```bash
fly logs --app <APP_NAME> | grep '"action":"submit"' | \
  python3 -c "
import sys, json
durations = []
for line in sys.stdin:
    try:
        d = json.loads(line)
        if d.get('action') == 'submit':
            durations.append(d['duration'])
    except: pass
if durations:
    print(f'Count: {len(durations)}, P50: {sorted(durations)[len(durations)//2]:.1f}ms, Max: {max(durations):.1f}ms')
"
```
**Breach indicator**: Any `duration` value > 500 in submit action logs.

### SLI-2: Nightly Queue Job Completion

**Definition**: `QueueBuilderJob` and `EmailDispatchJob` complete by 2:30 AM UTC.
**Target**: Both jobs complete within 30 minutes of the 2:00 AM schedule.
**Measurement**: `job_complete` log events timestamped before 02:30 UTC.
**How to check**:
```bash
fly logs --app <APP_NAME> | grep '"event":"job_complete"' | grep "QueueBuilderJob"
# Verify timestamp < 02:30 UTC
```
**Breach indicator**: No `job_complete` for `QueueBuilderJob` logged between 02:00 and 02:30 UTC on any day.

### SLI-3: Email Delivery Success Rate

**Definition**: Percentage of daily digest emails delivered without bounce.
**Target**: > 95% delivery rate.
**Measurement**: Postmark dashboard → Delivery rate per month.
**Expected volume**: ~30 emails/month (single user, daily). At this volume, even 1 bounce = 97% rate; 2 bounces = 93%.
**Breach indicator**: Any hard bounce from Postmark (permanent delivery failure to the user's email address).

### Note on SLOs

These SLIs are not formal SLOs in the uptime-guarantee sense. There is no SLA, no error budget, no stakeholder agreement on availability. The targets exist to catch regressions, not to fulfill a contract. A single-user personal tool does not warrant formal SLO management.

---

## Runbook Stubs

### RB-1: Fly Machine Crash / Crash Loop

**Symptoms**: Fly.io sends email alert; `fly status` shows machine state "stopped" or repeated restarts.

**Investigation**:
```bash
# Check machine status and restart count
fly status --app <APP_NAME>

# View recent logs around crash
fly logs --app <APP_NAME> -n 200

# Check for OOM (memory exceeded 256 MB)
fly logs --app <APP_NAME> | grep -i "memory\|oom\|killed"

# Check deploy history
fly releases --app <APP_NAME>
```

**Resolution steps**:
1. If crash is due to failed migration: check `fly releases` for the failed release; run `fly deploy --image <previous-image>` to rollback.
2. If crash is due to OOM: increase VM memory temporarily via `fly scale memory 512 --app <APP_NAME>` and investigate the memory leak.
3. If crash is due to application exception at startup: check logs for the exception; fix and redeploy.
4. If crash is due to Fly infrastructure issue: check https://status.fly.io.

**Rollback command**:
```bash
# Roll back to previous release
fly releases --app <APP_NAME>        # Find previous release version number
fly deploy --image <previous-image-ref> --app <APP_NAME>
```

---

### RB-2: Email Delivery Failure

**Symptoms**: No daily digest email received; Postmark webhook logs a bounce; `EmailDispatchJob` logs an error.

**Investigation**:
```bash
# Check job logs for error
fly logs --app <APP_NAME> | grep "EmailDispatchJob"

# Check Postmark dashboard for delivery status
# https://account.postmarkapp.com → Activity

# Check if email_sent_at was set (prevents re-send)
fly postgres connect --app <APP_NAME>-db
# SELECT user_id, queue_date, email_sent_at FROM daily_queues ORDER BY queue_date DESC LIMIT 5;
```

**Resolution steps**:
1. If `POSTMARK_API_TOKEN` is invalid/expired: rotate the token in Postmark dashboard, update Fly secret with `fly secrets set POSTMARK_API_TOKEN=<new-token>`.
2. If bounce is a hard bounce (bad email address): verify the user's email address in the database.
3. If `email_sent_at` is NULL (job ran but email failed silently): the retry logic in `EmailDispatchJob` should re-attempt once after 15 minutes. Check logs for the retry.
4. If retry also failed: manually trigger by resetting `email_sent_at` to NULL and re-enqueueing the job via `fly ssh console`:
   ```bash
   fly ssh console --app <APP_NAME>
   bin/rails runner "DailyQueue.where(queue_date: Date.today).update_all(email_sent_at: nil); EmailDispatchJob.perform_later"
   ```

---

### RB-3: Database Unreachable

**Symptoms**: `/up` health check returns 500; application logs show `PG::ConnectionBad`; Fly machine may restart.

**Investigation**:
```bash
# Check Postgres machine status
fly status --app <APP_NAME>-db

# Check Postgres logs
fly logs --app <APP_NAME>-db

# Attempt manual connection
fly postgres connect --app <APP_NAME>-db
```

**Resolution steps**:
1. If Fly Postgres machine is stopped: `fly machines start --app <APP_NAME>-db`.
2. If database volume is full: `fly volumes extend <volume-id> --size-gb 2 --app <APP_NAME>-db`.
3. If Postgres is unhealthy (corrupt state): check Fly Postgres documentation for restore from snapshot procedures.
4. If connection pool exhausted: review app logs for connection leak; restart app machine: `fly machines restart --app <APP_NAME>`.

**Check disk usage**:
```bash
fly postgres connect --app <APP_NAME>-db
SELECT pg_size_pretty(pg_database_size('ruby_learn_production')) AS db_size;
```
