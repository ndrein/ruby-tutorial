# JTBD Opportunity Scores — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 1
**Date**: 2026-03-09
**Source**: opportunity-tree.md scores + job story mapping from jtbd-job-stories.md

---

## Scoring Formula

Score = Importance + Max(0, Importance - Satisfaction)

Where:
- Importance = how important is solving this problem to the user (1-10)
- Satisfaction = how well existing solutions currently satisfy this need (1-10)
- A score above 10 signals a strong opportunity (underserved at high importance)

Scores sourced from opportunity-tree.md Phase 2 outputs; this document adds the job story
mapping layer required for DISCUSS traceability.

---

## Opportunity-to-Job Story Mapping

| Opportunity | Score | Primary Job Story | Secondary Job Story | Priority |
|-------------|-------|------------------|--------------------|---------:|
| OPP-2: Automated daily queue | **16** | JS-3 (Automated Review Queue) | JS-2 (Daily Habit) | 1st |
| OPP-1: Expert content calibration | **15** | JS-1 (Syntax Transfer) | JS-5 (Progress Visibility) | 2nd (tie) |
| OPP-3: Session length discipline | **15** | JS-2 (Daily Habit) | JS-3 (Queue) | 2nd (tie) |
| OPP-4: Keyboard-native interface | **12** | JS-4 (Keyboard Nav) | all journeys | 4th (tie) |
| OPP-5: Idiomatic Ruby emphasis | **12** | JS-1 (Syntax Transfer) | JS-5 (Progress) | 4th (tie) |
| OPP-7: Progress visibility | **11** | JS-5 (Progress Visibility) | JS-2 (Habit) | 6th |
| OPP-6: Rails extensibility | **7** | post-MVP | — | Post-MVP |

---

## Detailed Opportunity Analysis

### OPP-2: Automated Daily Queue (Score: 16 — Highest Priority)

**Job Story**: JS-3 (Automated Review Queue)
**Importance**: 9 | **Satisfaction**: 2 | **Score**: 9 + 7 = 16

**Why highest priority**:
This is the core differentiator. Without SM-2 automation, the platform is just a static
curriculum with exercises — the same as every other tool. The automated queue is what
makes daily practice sustainable and removes the decision fatigue that kills learning habits.

**Four Forces alignment**:
- Push: no existing tool (used by Marcus) provides an automated Ruby syntax review queue
- Pull: SM-2 scheduling removes all "what do I study today?" overhead
- Anxiety addressed by: transparent daily email showing queue before session starts
- Habit change required: trust the queue; do not manually select topics

**Solution ideas from opportunity-tree.md**:
- Idea 2A: SM-2 spaced repetition drives daily review queue automatically (CORE)
- Idea 2B: Daily email digest with queued exercises pre-selected (CORE)
- Idea 2C: Push notification at configured time showing today's queue (POST-MVP)

**MVP scope**: Ideas 2A + 2B are in scope. Idea 2C (push notifications) is post-MVP.

---

### OPP-1: Expert Content Calibration (Score: 15 — 2nd Priority)

**Job Story**: JS-1 (Syntax Transfer)
**Importance**: 9 | **Satisfaction**: 3 | **Score**: 9 + 6 = 15

**Why critical**:
Content calibration failure is a product failure. If the first lesson explains what a
variable is, Marcus will close the tab and not return. Expert calibration is a hard
requirement, not a nice-to-have.

**Four Forces alignment**:
- Push: executeprogram.com covers similar ground but is calibrated for earlier-stage learners
- Pull: 25-lesson curriculum starting at blocks/procs/symbols (skipping variables/OOP/loops)
- Anxiety addressed by: visible curriculum map showing "what this assumes you know" upfront
- Habit change required: proactive learning before need arises (not just lookup-on-demand)

**Solution ideas from opportunity-tree.md**:
- Idea 1A: Expert mode skipping OOP/variables/loops/conditionals entirely (CORE)
- Idea 1B: Prerequisite-aware curriculum mapping Python/Java concepts to Ruby equivalents (CORE)
- Idea 1C: Adaptive difficulty gating lessons on demonstrated prior knowledge (POST-MVP)

**MVP scope**: Ideas 1A + 1B are in scope. Adaptive difficulty (1C) is post-MVP.

---

### OPP-3: Session Length Discipline (Score: 15 — 2nd Priority)

**Job Story**: JS-2 (Daily Practice Habit)
**Importance**: 9 | **Satisfaction**: 3 | **Score**: 9 + 6 = 15

**Why critical**:
The 15-minute daily cap is not a preference — it is a hard constraint from Marcus's
attention budget. A tool that regularly exceeds this will be abandoned by week 2. Session
discipline must be structural (enforced by the product), not willpower-dependent.

**Four Forces alignment**:
- Push: existing tools have no end state; sessions run as long as Marcus stays
- Pull: predictable 15-minute sessions + session summary with time spent = trust
- Anxiety addressed by: 30-second exercise timer, session progress indicator, hard stop
- Habit change required: commit to daily session by knowing it will end on time

**Solution ideas from opportunity-tree.md**:
- Idea 3A: Enforce 30-second exercise time cap with auto-advance (CORE)
- Idea 3B: Separate review queue (30-sec each) from new lesson (<=5 min) (CORE)
- Idea 3C: Session summary showing time spent vs. target (CORE)

**MVP scope**: All three ideas are in scope for MVP.

---

### OPP-4: Keyboard-Native Interface (Score: 12 — 4th Priority)

**Job Story**: JS-4 (Keyboard Navigation)
**Importance**: 7 | **Satisfaction**: 2 | **Score**: 7 + 5 = 12

**Why important**:
This is a developer UX differentiator. It does not create learning value on its own, but
its absence creates friction that accumulates across every session. A mouse-dependent
learning interface is a daily irritant for a vim/terminal-native developer.

**Four Forces alignment**:
- Push: every existing learning tool requires mouse for submission and navigation
- Pull: Enter/j/k map directly to Marcus's existing muscle memory
- Anxiety addressed by: visible keyboard shortcut reference in UI (not hidden documentation)
- Habit change: low resistance — Marcus already prefers keyboard; he is breaking the habit
  of using mouse-dependent tools, not the keyboard habit itself

**Solution ideas from opportunity-tree.md**:
- Idea 4A: Full keyboard navigation: j/k, Enter, Esc (CORE)
- Idea 4B: Visible focus states (2px+ ring, 3:1+ contrast) (CORE)
- Idea 4C: Vim-mode shortcuts as optional layer (POST-MVP consideration)

**MVP scope**: Ideas 4A + 4B are in scope. Vim-mode (4C) is aspirational.

---

### OPP-5: Idiomatic Ruby Emphasis (Score: 12 — 4th Priority)

**Job Story**: JS-1 (Syntax Transfer) + JS-5 (Progress Visibility)
**Importance**: 8 | **Satisfaction**: 4 | **Score**: 8 + 4 = 12

**Why important**:
Learning Ruby syntax without learning Ruby idioms produces code that "looks Java" even
when syntactically correct. The expert-developer audience can absorb idiomatic framing;
they appreciate it as the higher-value content.

**Four Forces alignment**:
- Push: most Ruby content teaches syntax rules without cultural context ("why would you
  do this in Ruby vs. Python?")
- Pull: side-by-side Python/Java → Ruby comparisons in every lesson make transfer faster
- Anxiety: lower — this enhances content quality without adding risk

**Solution ideas from opportunity-tree.md**:
- Idea 5A: Python/Java equivalent side-by-side in each lesson (CORE)
- Idea 5B: Lessons show common Ruby idioms (blocks, procs, symbols) not just rules (CORE)
- Idea 5C: Lesson progression follows "from Java/Python habit to Ruby idiom" narrative (CORE)

**MVP scope**: All three ideas integrated into curriculum design for all 25 lessons.

---

### OPP-7: Progress Visibility (Score: 11 — 6th Priority)

**Job Story**: JS-5 (Progress Visibility)
**Importance**: 7 | **Satisfaction**: 3 | **Score**: 7 + 4 = 11

**Why included in MVP**:
Progress visibility sustains the habit (reinforcing JS-2). Without a dashboard, the SM-2
engine is a black box and Marcus cannot tell if his investment is yielding results.
A minimal dashboard is required for habit reinforcement, even if it is simple.

**Solution ideas from opportunity-tree.md**:
- Idea 7A: Dashboard showing retention rate per concept over time (CORE)
- Idea 7B: Mastered / In Review / New concept counts (CORE)
- Idea 7C: Weekly summary email showing concepts learned and streak (POST-MVP)

**MVP scope**: Ideas 7A + 7B are in scope. Weekly email (7C) is post-MVP.

---

### OPP-6: Rails Extensibility (Score: 7 — Post-MVP)

**Job Story**: Not mapped to any MVP job story
**Importance**: 6 | **Satisfaction**: 5 | **Score**: 6 + 1 = 7

**Why post-MVP**:
Score of 7 is below the threshold for MVP inclusion. Marcus mentions Rails as a future
desire, but his immediate job is Ruby syntax fluency. Rails content cannot be built until
the Ruby foundation exists. No design decisions in the MVP should foreclose the Rails
extension, but no story is written for it now.

---

## Prioritized Summary for Story Creation

Stories will be created in priority order corresponding to these opportunities:

| Priority | Opportunity | Job Stories | MVP Milestone |
|----------|-------------|-------------|--------------|
| 1 | OPP-2: SM-2 review queue | JS-3, JS-2 | M4: SM-2 Engine |
| 2 | OPP-1: Expert content | JS-1 | M8: Lesson Content |
| 3 | OPP-3: Session discipline | JS-2, JS-3 | M2: Daily Session |
| 4 | OPP-4: Keyboard nav | JS-4 | M7: Keyboard Navigation |
| 5 | OPP-5: Ruby idioms | JS-1, JS-5 | M8: Lesson Content |
| 6 | OPP-7: Progress visibility | JS-5 | M6: Progress Dashboard |
| F0 | Walking Skeleton | JS-1, JS-3 | M0: Walking Skeleton |
| F1 | Onboarding | JS-1, JS-2 | M1: Onboarding |
| F2 | Exercise UX | JS-3, JS-4 | M5: Exercise Timer |
