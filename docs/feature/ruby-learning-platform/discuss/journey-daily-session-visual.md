# Journey Map: Daily Session — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Journey**: Daily Session (morning email → review queue → optional lesson → session summary)
**Primary Job Story**: JS-2 (Daily Practice Habit) + JS-3 (Automated Review Queue)
**Emotional Arc**: Intent → Flow → Satisfaction → Streak Pride
**Date**: 2026-03-09

---

## Journey Overview

Marcus Chen has been using the platform for one week. It is Thursday morning, 8:47 AM,
13 minutes before standup. He opens his email, sees today's review queue, clicks the link,
works through 4 exercises (the SM-2 queue for today), reads Lesson 3, completes its exercise,
and sees his session summary showing 11 minutes used of his 15-minute budget. His streak
is now 7 days.

**Goal**: Marcus finishes feeling productive, on-time, and proud of an unbroken streak.

---

## Journey Map Table

| Step | Action | Touchpoint | Marcus Thinks | Marcus Feels | Pain Points | Shared Artifacts |
|------|--------|-----------|--------------|-------------|-------------|-----------------|
| 1. Email Arrival | Morning email arrives at 8:00 AM | Daily digest email in inbox | "Today's queue: 4 reviews + 1 new lesson. 10 minutes. I have time." | Intent formed, confidence present | Email at wrong time kills the habit trigger | `${review_queue}`, `${queue_count}` |
| 2. App Open | Marcus clicks link from email → app opens to session start | Session start screen showing today's queue | "I can see exactly what I'm doing today before I start" | Oriented, in control | Ambiguity about what is in the queue = friction | `${review_queue}`, `${lesson_id}` |
| 3. Review Exercise 1 | First SM-2 review exercise appears | Exercise 1 of 4 (30-sec timer) | "Ruby symbols vs strings — I remember this from last week" | Confident, recall forming | Timer pressure if exercise too hard | `${exercise_id}`, `${timer_seconds}`, `${sm2_score}` |
| 4. Review Exercise 2 | Second review appears after Enter | Exercise 2 of 4 | "Blocks with yield... I need a second. Oh right — `yield` calls the block" | Slight hesitation then click of recognition | "Oh right" moment = ideal SM-2 timing | `${exercise_id}`, `${sm2_score}` |
| 5. Review Exercise 3 | Third review exercise | Exercise 3 of 4 | "attr_accessor — this is muscle memory now" | Fluent, fast | No pain — this is mastery feeling | `${exercise_id}`, `${sm2_score}` |
| 6. Review Exercise 4 | Fourth review exercise | Exercise 4 of 4 | "Comparable... which method was it? sort? <=> ? I'll say `<=>`" | Uncertain, guessing — correct | Productive uncertainty; SM-2 timed this right | `${exercise_id}`, `${sm2_score}` |
| 7. Review Queue Complete | "Queue complete" screen | Queue summary panel | "4 exercises, 4 minutes. Queue done." | Satisfied, small victory | No pain — clear done state for review portion | `${queue_count}`, `${review_duration}` |
| 8. New Lesson Option | Prompted: "Start Lesson 3?" | Lesson prompt with estimated time | "3 minutes estimated. I have 11 minutes left. Yes." | Agency — it's an offer, not a demand | Mandatory lesson after review would break the choice | `${lesson_id}`, `${time_remaining}` |
| 9. Lesson 3 Content | Reads Lesson 3: Procs vs Lambdas | Lesson view with Python comparison | "Python has lambda. Ruby has proc AND lambda. And they differ on return? Important." | Engaged, learning, slight complexity | Complexity spike: proc vs lambda is nuanced | `${lesson_content}`, `${lesson_id}` |
| 10. Lesson Exercise | Completes exercise for Lesson 3 | Exercise with 30-second timer | "It's about how return behaves inside a lambda — got it" | Confident in new concept | — | `${exercise_id}`, `${sm2_score}`, `${timer_seconds}` |
| 11. SM-2 Scheduling | Sees new lesson scheduled | SM-2 panel: "Procs vs Lambdas — review in 3 days" | "Automatic. I don't have to think about when to review this" | Trusting, relieved | — | `${next_review_date}`, `${sm2_interval}` |
| 12. Session Summary | Reviews session summary | Session end screen with all metrics | "11 min 24 sec. 7-day streak. Under target. Perfect." | Proud, streak satisfaction, habit reinforced | — | `${session_duration}`, `${streak_count}`, `${lessons_completed}` |

---

## Emotional Arc Visualization

```
Intent       Flow (exercises)         Satisfaction    Streak Pride
  |            |     |    |    |           |               |
  v            v     v    v    v           v               v
 [1][2]  --> [3]   [4]  [5]  [6]  -->  [7][8]  -->  [9][10][11] --> [12]


    INTENT                                              STREAK PRIDE
    +-----------------------------------------------------------+
    |                                                           |
    |  ..        ___________                         ___________|
    | .  .      /           \           ____________/           |
    |.    .    /  FLOW zone  \         /  new lesson            |
    |     .   /    reviews    \       /                         |
    |      . /                 \_____/                          |
    |                           queue                           |
    |                           done                            |
    +--+--+--+--+--+--+--+--+--+--+--+--+-------------------+--+
       1  2  3  4  5  6        7  8  9  10 11                12
```

---

## TUI Mockups

### Step 1: Daily Email

```
From: RubyFlow <queue@rubyflow.app>
To: marcus@example.com
Subject: Today's Queue — 4 reviews + 1 lesson option (est. 10 min)

Good morning, Marcus.

Today's review queue (SM-2 scheduled):
  1. Ruby Symbols vs Strings (Lesson 2)
  2. Blocks with yield (Lesson 1)
  3. attr_accessor (Lesson 11)
  4. Comparable module (Lesson 22)

New lesson available:
  Lesson 3: Procs vs Lambdas (~3 min)

Total estimated time: 8-10 minutes

[ Open Today's Session ]  →  https://rubyflow.app/session/today

Streak: 6 days  |  Mastered: 12  |  In Review: 8
```

### Step 2: Session Start Screen

```
+----------------------------------------------------------+
|  RubyFlow — Today's Session                              |
|                                                          |
|  Thursday, March 12                                      |
|                                                          |
|  Review Queue (SM-2)           New Lesson (optional)     |
|  ----------------------        -------------------------  |
|  4 exercises                   Lesson 3: Procs vs        |
|  Estimated: 2-4 min            Lambdas (~3 min)          |
|                                                          |
|  1. Ruby Symbols vs Strings    [Available after queue]   |
|  2. Blocks with yield                                    |
|  3. attr_accessor                                        |
|  4. Comparable module                                    |
|                                                          |
|  [ Start Review Queue ]  (Enter)                         |
|                                                          |
|  Streak: 6 days  |  Budget remaining: 15:00              |
+----------------------------------------------------------+
```

### Step 3-6: Review Exercise (in progress)

```
+----------------------------------------------------------+
|  Review 2 of 4 — Ruby Blocks with yield        [0:22]    |
|                                                          |
|  What does yield do in this method?                      |
|                                                          |
|  def transform(arr)                                      |
|    arr.map do |x|                                        |
|      ________(x)   # <-- fill in                        |
|    end                                                   |
|  end                                                     |
|                                                          |
|  Your answer: [yield_____________]                       |
|                                                          |
|  Enter: submit  |  Esc: skip  |  h: hard  |  e: easy    |
|                                                          |
|  [===>                                ] Review 2/4       |
+----------------------------------------------------------+
```

### Step 7: Review Queue Complete

```
+----------------------------------------------------------+
|  Review Queue Complete                                   |
|                                                          |
|  4 exercises  |  3 min 47 sec                            |
|                                                          |
|  Results:                                                |
|  Ruby Symbols vs Strings    Correct   next: 7 days       |
|  Blocks with yield          Correct   next: 14 days      |
|  attr_accessor              Correct   next: 30 days      |
|  Comparable module          Correct   next: 7 days       |
|                                                          |
|  Budget remaining: 11 min 13 sec                         |
|                                                          |
|  New lesson available:                                   |
|  Lesson 3: Procs vs Lambdas (~3 min)                     |
|                                                          |
|  [ Start Lesson 3 ]  (Enter)    [ Done for today ] (Esc) |
+----------------------------------------------------------+
```

### Step 12: Session Summary

```
+----------------------------------------------------------+
|  Session Complete — Thursday, March 12                   |
|                                                          |
|  Reviews:         4 of 4 completed                       |
|  New lesson:      Lesson 3 — Procs vs Lambdas            |
|  Session time:    11 min 24 sec                          |
|  Daily target:    15 min                                 |
|  Under budget by: 3 min 36 sec                           |
|                                                          |
|  Streak:  7 days  ######### (keep it going)              |
|                                                          |
|  SM-2 updates:                                           |
|    Procs vs Lambdas  next review: March 15               |
|    Comparable module next review: March 19               |
|                                                          |
|  [ Dashboard ]  (g d)    [ Done ]  (Esc)                 |
+----------------------------------------------------------+
```

---

## Integration Checkpoints

| Checkpoint | What Must Be True | Risk if Wrong |
|-----------|------------------|---------------|
| Email queue matches app queue | `${review_queue}` in email must be identical to app queue on open | Marcus opens app and sees different exercises than email listed; disorienting |
| SM-2 timer → score | `${timer_seconds}` elapsed when submitted must inform `${sm2_score}` (fast = easy signal) | SM-2 interval incorrectly calibrated; reviews appear too soon or too late |
| Review duration tracked | `${review_duration}` must accumulate per exercise and roll up to session | Session summary shows wrong time |
| Streak increments once per day | `${streak_count}` increments on first completed session of the day only | Multiple sessions in a day inflate streak |
| Budget remaining updates live | `${time_remaining}` must update after each exercise | Marcus cannot gauge whether to start lesson |

---

## Pain Point Summary

| Step | Pain Point | Mitigation |
|------|-----------|------------|
| 1. Email | Wrong delivery time | User sets preferred email time during onboarding |
| 2. App open | Ambiguous queue content | Session start screen shows full queue list before starting |
| 4. Hard exercise | Timer anxiety on difficult recall | "h: mark hard" key available to invoke slower timer extension |
| 7. Queue done | Uncertainty about lesson choice | Remaining budget displayed next to lesson option |
| 12. Summary | Streak broken by travel/illness | Grace day policy (one missed day per 7 does not break streak) — post-MVP |
