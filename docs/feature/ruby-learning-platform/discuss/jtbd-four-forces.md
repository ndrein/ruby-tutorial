# JTBD Four Forces Analysis — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 1
**Date**: 2026-03-09
**Source**: Derived from interview-log.md signals + problem-validation.md pain points

---

## Framework

The Four Forces model explains what drives a user toward a new solution (Push, Pull)
and what holds them back from switching (Anxiety, Habit). For each job story, understanding
these forces reveals where the product must be strong enough to overcome resistance.

**Persona**: Marcus Chen — senior Python/Java developer, learning Ruby for a new team role.

---

## Job Story 1 — Syntax Transfer

**When** Marcus wants to become productive writing idiomatic Ruby in a new codebase,
**the current situation** is that he relies on a mix of executeprogram.com,
Ruby documentation, and ad-hoc searching whenever he gets stuck.

### Push Forces (driving away from current behavior)
- executeprogram.com content assumes an earlier-stage learner; Marcus spends the first
  sections of each module skipping material he already knows from Python
- Ruby documentation is comprehensive but not structured for syntax transfer — it does
  not say "if you know Python list comprehensions, here is the Ruby equivalent"
- Ad-hoc searching is unreliable for forming durable memories; Marcus answers the same
  question multiple times before it sticks
- Each lookup interrupts his flow while writing actual code

### Pull Forces (attracting toward new solution)
- A curriculum that starts at the point where Marcus actually is (knows OOP, blocks
  are the new concept, not conditionals) would save him 30-60 minutes per module
- Side-by-side Python/Java → Ruby comparisons would leverage his existing mental models
  rather than force him to build from scratch
- Content scoped to Ruby-specific idioms (symbols, blocks, procs, `Enumerable`) covers
  exactly what he lacks and nothing he already has

### Anxiety Forces (concerns about switching)
- "Will this tool assume I'm a beginner anyway?" — high anxiety based on every prior
  tool disappointing him on this dimension
- "Will the content be accurate and idiomatic?" — Marcus values correctness; wrong Ruby
  idioms taught at the syntax level would be worse than no tool
- "Will I end up with 30 tabs open during a session?" — fear that the platform creates
  more research overhead, not less

### Habit Forces (behaviors that must change)
- Current habit: look it up when stuck, forget it, look it up again
- Must change to: do a 5-minute lesson proactively in the morning, before the concept
  comes up in code
- Resistance: Marcus is not accustomed to proactive learning before a use case arises

---

## Job Story 2 — Daily Practice Habit

**When** Marcus wants to build a sustainable Ruby learning habit,
**the current situation** is that he tries to "find time" for learning but sessions
are unpredictably long and he often stops mid-module when time runs out.

### Push Forces
- Sessions on existing tools regularly run 20-40 minutes once Marcus gets into them;
  this makes him reluctant to start when he has less than an hour free
- No clear end state on existing tools ("keep learning" prompts, infinite scroll of content)
  means Marcus never knows when he is "done" for the day
- Missing a session derails him because there is no queue catching what he missed;
  he has to reconstruct where he was

### Pull Forces
- A 15-minute hard cap means Marcus can commit to starting the session even with tight time
- A pre-built daily queue removes the "what do I do today?" paralysis that causes him to
  skip sessions
- A session summary showing "you finished in 12 minutes" gives Marcus positive feedback
  and a clear done state
- A streak counter creates a loss-aversion signal that sustains habit ("I don't want to
  break a 7-day streak")

### Anxiety Forces
- "What if the queue takes longer than 15 minutes?" — Marcus needs the tool to enforce
  the cap, not rely on his willpower
- "What if I miss a day? Does the queue pile up?" — fear of a backlog that becomes
  unmanageable
- "What if the streak mechanic makes me feel bad rather than good?" — streak anxiety is
  real; gamification can backfire

### Habit Forces
- Current habit: open learning tool "when I have time" — no fixed slot, no commitment
- Must change to: 15-minute morning session before standup, daily, with a fixed queue
- Resistance: the existing "learn when inspired" pattern is deeply set; the tool must
  make starting so frictionless that the habit forms by default

---

## Job Story 3 — Automated Review Queue

**When** Marcus has finished learning a Ruby concept and knows he needs to retain it,
**the current situation** is that he has no system driving when to review; he either
reviews too soon (wasting time) or too late (has forgotten it already).

### Push Forces
- Anki would be the ideal SRS tool but requires Marcus to create all cards manually —
  the content production overhead is a blocker
- executeprogram.com has some SRS-like structure but does not implement SM-2 specifically
  and the content calibration problem (too beginner) makes it less useful
- Without a queue, Marcus has reviewed some concepts 5+ times (over-reviewing strong
  memories) while other concepts have gone unreviewed until they appear in code

### Pull Forces
- SM-2 automatically schedules each concept at the interval that maximizes retention
  per unit of review time — Marcus gets more retention value for the same 5-10 minutes
  of daily review
- Daily email showing today's queue removes all "what should I do today?" decision-making
- Automated queue means a missed day does not require manual reconstruction — Marcus
  just opens tomorrow's email and works the queue

### Anxiety Forces
- "Is SM-2 tuned for syntax learning, or is it calibrated for language vocabulary cards?"
  — appropriate tuning anxiety; SM-2 defaults need to work for the Ruby syntax domain
- "Will the queue grow unmanageable if I miss several days?" — concern about exponential
  queue growth if life interrupts
- "How does the system know if I actually understood a concept or just guessed right?" —
  concern about quality of the review signal

### Habit Forces
- Current habit: review by re-reading notes or re-watching videos when something comes up
- Must change to: trust the queue and work it daily, even when nothing specific has come up
- Resistance: it feels unnatural to review something that "feels fine" — SM-2 may schedule
  reviews before Marcus consciously thinks he needs them

---

## Job Story 4 — Keyboard-Native Navigation

**When** Marcus is in a review session and needs to submit answers or navigate exercises,
**the current situation** is that every learning tool forces him to reach for the mouse
to click "Submit" or "Next" — breaking his typing flow.

### Push Forces
- Clicking "Submit" with a mouse after typing an answer adds friction to every single
  exercise interaction — multiplied across 5-10 exercises per session, this is significant
- Mouse-dependent interfaces signal that the tool was not built with developers in mind —
  this reduces Marcus's trust in the product's judgment
- Focus state visibility is often absent on learning tools; Marcus cannot tell which
  element is focused without a mouse hover

### Pull Forces
- `Enter` to submit is the natural termination of "I typed my answer" — this is how
  Marcus's terminal and editor work
- `j`/`k` navigation is muscle memory from vim; he does not need to learn new shortcuts
- Visible focus ring (high contrast) means Marcus can always see exactly where he is
  without guessing

### Anxiety Forces
- "Are the shortcuts consistent everywhere in the app?" — keyboard nav that works in
  one section but not another is worse than no keyboard nav
- "Will I accidentally trigger a shortcut while typing an answer?" — risk of modal
  confusion (vim's insert mode problem translated to a learning app)
- "Will I need to read documentation to find the shortcuts?" — shortcuts must be
  discoverable, ideally from the UI itself

### Habit Forces
- Current habit: reach for mouse to click interactive elements on web tools
- Must change to: type answer, press Enter, use j/k to navigate
- Resistance: low — this is the behavior Marcus prefers; he is resisting the habit of
  using the mouse, not the habit of using the keyboard

---

## Job Story 5 — Progress Visibility

**When** Marcus wants to gauge how his Ruby learning is progressing after several weeks,
**the current situation** is that he has no consolidated view of what he knows, what is
fading, and what he has not yet covered.

### Push Forces
- With no dashboard, Marcus cannot answer "how far am I?" without mentally reconstructing
  his session history
- He cannot tell if his retention is improving or stagnating — the tool gives no feedback
  at the outcome level, only at the exercise level
- No streak visibility means the habit has no external reinforcer

### Pull Forces
- A mastery count ("24 concepts mastered, 3 in review, 5 new") gives Marcus a concrete
  sense of progress he can hold in his head
- A retention rate metric transforms SM-2 from a black box into a visible system Marcus
  can trust
- Streak count gives Marcus a loss-aversion anchor that sustains the daily habit

### Anxiety Forces
- "Will the dashboard make me feel bad about my progress?" — gamification backlash risk;
  if metrics are punitive, they damage motivation
- "Is the retention rate calculated correctly?" — Marcus wants to understand the metric,
  not just see a number
- "Does this create pressure to do lessons I am not ready for?" — progress visibility
  should not push Marcus toward content before the SM-2 queue is ready

### Habit Forces
- Current habit: operate without visibility into learning progress; rely on "feel"
- Must change to: check dashboard weekly to assess trajectory, not just daily to complete sessions
- Resistance: low — Marcus already values metrics and instrumentation; he will adopt this
  easily once the dashboard exists

---

## Four Forces Summary Matrix

| Force | JS-1 Syntax | JS-2 Habit | JS-3 Queue | JS-4 Keyboard | JS-5 Progress |
|-------|-------------|-----------|-----------|--------------|--------------|
| Push (strongest) | Tools assume beginners | Sessions have no end state | No automated queue | Mouse required for every action | No consolidated progress view |
| Pull (strongest) | Expert-calibrated content | 15-min cap + done state | SM-2 + daily email | Enter/j/k muscle memory | Mastery count + retention rate |
| Anxiety (highest) | "Will it assume beginner anyway?" | "What if queue exceeds 15 min?" | "Is SM-2 tuned correctly?" | "Are shortcuts consistent everywhere?" | "Will metrics feel punitive?" |
| Habit (hardest) | Switching from reactive to proactive learning | Fixed morning session vs. "when inspired" | Trusting queue before need is felt | Low resistance — natural preference | Low resistance — values metrics |
