# Opportunity Tree — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: 2 — Opportunity Mapping
**Gate**: G2
**Date**: 2026-03-08

---

## Desired Outcome

**Primary outcome**: "As an experienced developer, I acquire Ruby syntax fluency through 15 minutes of daily practice, driven by automated spaced repetition, without re-learning concepts I already know from Python and Java."

**Success looks like**:
- Can write idiomatic Ruby without documentation lookup after N weeks of daily practice
- Daily session never exceeds 15 minutes
- Review queue is automatically generated — no manual curation
- Streak/habit maintained for 30+ days

---

## Opportunity Solution Tree

```
DESIRED OUTCOME: Ruby syntax fluency via automated daily practice (<=15 min/day)
  |
  +-- OPP-1: Minimize time lost to beginner content for expert learners (score: 15)
  |     +-- Idea 1A: Expert mode that skips OOP/variables/loops/conditionals entirely
  |     +-- Idea 1B: Prerequisite-aware curriculum that maps Python/Java concepts to Ruby equivalents
  |     +-- Idea 1C: Adaptive difficulty that gates lessons on demonstrated prior knowledge
  |
  +-- OPP-2: Minimize decision effort to know what to practice each day (score: 14)
  |     +-- Idea 2A: SM-2 spaced repetition drives daily review queue automatically
  |     +-- Idea 2B: Daily email digest with 2-3 queued exercises pre-selected
  |     +-- Idea 2C: Push notification at configured time showing today's queue
  |
  +-- OPP-3: Minimize session length while maximizing retention signal per minute (score: 13)
  |     +-- Idea 3A: Enforce 30-second exercise time cap with auto-advance
  |     +-- Idea 3B: Separate review queue (30-sec each) from new lesson (<=5 min)
  |     +-- Idea 3C: Session summary showing time spent vs. target (feedback loop)
  |
  +-- OPP-4: Minimize interface friction for keyboard-native developers (score: 12)
  |     +-- Idea 4A: Full keyboard navigation: j/k navigation, Enter to submit, Esc to skip
  |     +-- Idea 4B: Visible focus states with high-contrast ring on all interactive elements
  |     +-- Idea 4C: Vim-mode shortcuts as optional layer
  |
  +-- OPP-5: Minimize gap between Ruby syntax and working idiomatic code (score: 11)
  |     +-- Idea 5A: Each lesson includes a "Python equivalent / Java equivalent" side-by-side
  |     +-- Idea 5B: Lessons show common Ruby idioms (blocks, procs, symbols) not just syntax rules
  |     +-- Idea 5C: Lesson progression follows "from Java/Python habit to Ruby idiom" narrative
  |
  +-- OPP-6: Minimize friction to extend learning into Rails later (score: 8)
  |     +-- Idea 6A: Course catalog includes Ruby Core -> Ruby Advanced -> Rails track
  |     +-- Idea 6B: Rails lessons reuse same SRS engine and daily queue mechanism
  |     +-- Idea 6C: Rails content gated behind Ruby proficiency threshold
  |
  +-- OPP-7: Minimize uncertainty about learning progress and retention (score: 9)
        +-- Idea 7A: Dashboard showing retention rate per concept over time
        +-- Idea 7B: "Mastered" vs "In review" vs "New" concept counts
        +-- Idea 7C: Weekly summary email showing concepts learned and streak
```

---

## Opportunity Scoring

**Formula**: Score = Importance + Max(0, Importance - Satisfaction)
**Source**: Derived from Phase 1 interview signals and JTBD importance/satisfaction ratings.

| Opportunity | Importance (I) | Satisfaction (S) | Score = I + Max(0, I-S) | Priority |
|-------------|---------------|-----------------|------------------------|----------|
| OPP-1: Expert content calibration | 9 | 3 | 9 + 6 = **15** | Pursue |
| OPP-2: Automated daily queue | 9 | 2 | 9 + 7 = **16** | Pursue |
| OPP-3: Session length discipline | 9 | 3 | 9 + 6 = **15** | Pursue |
| OPP-4: Keyboard-native interface | 7 | 2 | 7 + 5 = **12** | Pursue |
| OPP-5: Idiomatic Ruby vs. syntax rules | 8 | 4 | 8 + 4 = **12** | Pursue |
| OPP-7: Progress visibility | 7 | 3 | 7 + 4 = **11** | Pursue |
| OPP-6: Rails extensibility | 6 | 5 | 6 + 1 = **7** | Evaluate |

All top opportunities score >8. OPP-6 (Rails) scores 7 — valid future opportunity, not MVP priority.

**Sorted by score**:
1. OPP-2: Automated daily queue — **16**
2. OPP-1: Expert content calibration — **15** (tie)
3. OPP-3: Session length discipline — **15** (tie)
4. OPP-4: Keyboard-native interface — **12** (tie)
5. OPP-5: Idiomatic Ruby emphasis — **12** (tie)
6. OPP-7: Progress visibility — **11**
7. OPP-6: Rails extensibility — **7** (post-MVP)

---

## Job Map Coverage

Using JTBD Universal Job Map steps for the job "learn Ruby syntax":

| Job Step | Covered by Opportunity | Coverage |
|----------|----------------------|---------|
| Define (what needs learning today) | OPP-2: automated queue decides | COVERED |
| Locate (find the right content) | OPP-1: expert-calibrated catalog | COVERED |
| Prepare (ready to practice) | OPP-4: keyboard nav, instant access | COVERED |
| Confirm (is this the right level?) | OPP-1: expert mode, skip basics | COVERED |
| Execute (do the practice) | OPP-3: 30-sec exercises, <=5-min lessons | COVERED |
| Monitor (how am I doing?) | OPP-7: progress dashboard | COVERED |
| Modify (adjust difficulty/pacing) | OPP-2: SM-2 adapts automatically | COVERED |
| Conclude (done for today?) | OPP-3: session summary, time feedback | COVERED |

**Job step coverage: 8/8 = 100%** — all steps addressed.

---

## Top 3 Opportunities Selected for Solution Design

**OPP-2: Automated daily queue** (score 16) — Core differentiator. SM-2 removes the daily "what do I study" decision entirely. Without this, the product is just another static curriculum.

**OPP-1: Expert content calibration** (score 15) — Primary content differentiation. If the lessons still explain what a variable is, the product fails its core promise. This is the curriculum design challenge.

**OPP-3: Session length discipline** (score 15) — The habit engine. The product must enforce its own time constraint — not rely on user willpower. Auto-advance, session caps, and time feedback are structural requirements.

**OPP-4 and OPP-5 are strong supporting opportunities** incorporated into solution design for top 3 — keyboard nav and idiomatic framing enhance all three top opportunities.

---

## G2 Gate Evaluation

| Criterion | Target | Result | Status |
|-----------|--------|--------|--------|
| Opportunities identified | 5+ distinct | 7 distinct opportunities | PASS |
| Top scores | >8 / max 20 | Top 6 all >8; highest = 16 | PASS |
| Job step coverage | 80%+ | 100% (8/8 steps covered) | PASS |
| Team alignment | Confirmed | Builder = sole stakeholder; aligned by definition | PASS |
| Top 2-3 prioritized | Required | OPP-2, OPP-1, OPP-3 selected with rationale | PASS |

**G2 Decision: PROCEED to Phase 3 — Solution Testing**
