# JTBD Job Stories — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 1
**Date**: 2026-03-09
**Source**: Expanded from problem-validation.md JTBD map + interview-log.md signals

---

## Grounding

These job stories are derived directly from the 5 jobs identified in the DISCOVER phase
(problem-validation.md, interview-log.md). Each job has been expanded with:
- Full job story format: When [situation] / I want to [motivation] / So I can [outcome]
- Three job dimensions: Functional, Emotional, Social
- The primary persona: Marcus Chen, an experienced Python + Java developer

### Persona: Marcus Chen
- Senior software engineer, 8 years experience in Python and Java
- Joining a team that uses Ruby on Rails; needs to become productive quickly
- Works in a terminal-first environment; vim user; mouse is a context switch
- Has 15 minutes in the morning before standup — that is his learning window
- Has tried executeprogram.com; found it useful but not calibrated for his level
- Values information density; skims documentation rather than reading linearly

---

## Job Story 1 — Syntax Transfer

**Job**: Transfer syntax knowledge from Python/Java to Ruby

**When** I sit down to prepare for a Ruby codebase review and realize I keep mentally
translating Python syntax into Ruby while writing,
**I want to** systematically close the gap between what I know from Python and Java and
what Ruby-specific syntax looks like,
**So I can** write idiomatic Ruby on the first pass without stopping to look up whether
it is `end` or `}` or how symbols differ from strings.

**Importance (DISCOVER)**: 9/10
**Current Satisfaction (DISCOVER)**: 4/10
**Opportunity Score**: 15 (OPP-1)

### Functional Dimension
Marcus needs to learn which Python/Java constructs have Ruby equivalents that look different
(string interpolation, method definitions, blocks) and which have no direct equivalent at all
(symbols, procs vs. lambdas, `method_missing`). He does not need to learn what a loop is.

### Emotional Dimension
Marcus feels frustrated when he opens a Ruby tutorial and the first three sections explain
variables and conditionals. He feels respected when content assumes his prior knowledge.
He feels confident when he can map a new concept directly onto something he already knows.

### Social Dimension
Marcus wants to be able to hold his own in code review within his new team without
prefacing every comment with "I'm still learning Ruby." Fluency is a professional signal.

---

## Job Story 2 — Daily Practice Habit

**Job**: Maintain daily practice habit within attention budget

**When** I want to improve at Ruby but my day is already packed with meetings and coding
work and I only have a small window before standup,
**I want to** complete a meaningful practice session in 15 minutes or less that still
builds real retention,
**So I can** maintain a consistent daily habit without feeling like I am sacrificing
something else to do it.

**Importance (DISCOVER)**: 9/10
**Current Satisfaction (DISCOVER)**: 3/10
**Opportunity Score**: 15 (OPP-3)

### Functional Dimension
Marcus needs a session structure that is predictably bounded. He needs to know before
starting that he will finish in time. The session must have a clear end state — not an
open-ended "keep going as long as you want" model.

### Emotional Dimension
Marcus feels anxious starting a learning session if he does not know how long it will take.
He feels in flow when the content is right at his level and advances without friction.
He feels satisfaction — and pride — when he completes a streak without breaking it.

### Social Dimension
Daily habit is a personal value signal for Marcus. He is the kind of developer who has
dotfiles, maintains a personal knowledge base, and takes craftsmanship seriously. A
consistent learning practice reinforces this identity.

---

## Job Story 3 — Automated Review Queue

**Job**: Know what to review without manual decision-making

**When** I finish a lesson and know I will need to remember this Ruby concept in two weeks
but I am not sure when to review it to retain it optimally,
**I want to** have the system decide what I should review today based on what I have
already learned and how well I remembered it last time,
**So I can** trust that the review queue contains exactly what I need without spending
mental energy curating it myself.

**Importance (DISCOVER)**: 8/10
**Current Satisfaction (DISCOVER)**: 2/10
**Opportunity Score**: 16 (OPP-2, highest priority)

### Functional Dimension
Marcus needs an algorithm (SM-2) that tracks his response quality for each concept and
schedules reviews at expanding intervals. He needs a daily queue delivered to him —
he opens the app, the queue is there, he works through it. No decisions required.

### Emotional Dimension
Marcus feels relieved when he opens the app and the question "what should I study today?"
is already answered. He feels trust in a system that proves it knows when he is about to
forget something. He feels anxious when he suspects he has forgotten something but does
not know how to find it.

### Social Dimension
Lower social dimension than other jobs — this is an internal efficiency preference, not
a signal to others. However, the resulting fluency (from better retention) is socially visible.

---

## Job Story 4 — Keyboard-Native Navigation

**Job**: Navigate learning UI without leaving keyboard

**When** I am in the middle of a review session and need to submit my answer or move to
the next exercise,
**I want to** use keyboard shortcuts consistent with the tools I already use (vim, terminal)
to navigate the learning interface without reaching for the mouse,
**So I can** stay in a focused flow state without the context switch of switching input
modes.

**Importance (DISCOVER)**: 7/10
**Current Satisfaction (DISCOVER)**: 2/10
**Opportunity Score**: 12 (OPP-4)

### Functional Dimension
Marcus needs `Enter` to submit, `j`/`k` to navigate, `Esc` to skip or dismiss, and visible
focus states on all interactive elements. The entire session must be completable without
touching a mouse.

### Emotional Dimension
Marcus feels friction every time he reaches for the mouse in an interface that "should" be
keyboard-navigable. He feels respected by an interface that acknowledges he is a developer.
He feels invisible when an interface treats him like a casual web user.

### Social Dimension
Keyboard-native UX is a proxy for "built by developers for developers." This matters to
Marcus as a signal of product quality and intent.

---

## Job Story 5 — Progress Visibility

**Job**: Extend Ruby knowledge toward idiomatic fluency and track progress

**When** I want to understand where I am in my Ruby learning journey and how well my
retention is holding up over time,
**I want to** see a clear view of how many concepts I have mastered, how many are in
review, and what my retention rate looks like,
**So I can** feel confident about my progress and know when I am ready to tackle more
advanced Ruby idioms or the Rails track.

**Importance (DISCOVER)**: 7/10
**Current Satisfaction (DISCOVER)**: 3/10
**Opportunity Score**: 11 (OPP-7)

### Functional Dimension
Marcus needs mastery counts (Mastered / In Review / New), a retention rate metric per
concept, a streak counter, and a sense of how far through the curriculum he is. This is
a dashboard view, not a per-session view.

### Emotional Dimension
Marcus feels uncertain about his progress when the only feedback is whether he got each
exercise right or wrong. He feels proud when a dashboard shows a concrete retention rate
improving over weeks. He feels motivated when a streak is visible and worth protecting.

### Social Dimension
Progress is not public in the MVP (personal tool). However, it supports Marcus's own
professional identity narrative: "I am someone who builds skills systematically."

---

## Job Story Cross-Reference

| Job Story | DISCOVER Job | OPP Mapping | Priority |
|-----------|-------------|-------------|----------|
| JS-1: Syntax Transfer | Transfer syntax knowledge from Python/Java | OPP-1 (score 15) | High |
| JS-2: Daily Practice Habit | Maintain daily practice within attention budget | OPP-3 (score 15) | High |
| JS-3: Automated Review Queue | Know what to review without manual decision | OPP-2 (score 16) | Highest |
| JS-4: Keyboard Navigation | Navigate learning UI without leaving keyboard | OPP-4 (score 12) | Medium-High |
| JS-5: Progress Visibility | Track progress and retention over time | OPP-7 (score 11) | Medium |
