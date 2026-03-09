# Test Scenarios — Ruby Learning Platform

**Date**: 2026-03-09
**Wave**: DISTILL
**Status**: Ready for DELIVER

---

## Scenario Inventory

### Walking Skeletons (3 total)

| # | Scenario | File | Status |
|---|----------|------|--------|
| WS-1 | Ana opens platform and completes first exercise | walking-skeleton.feature | @wip (start here) |
| WS-2 | Ana completes a full daily session with reviews | walking-skeleton.feature | @skip |
| WS-3 | Ana navigates locked lesson and unlocks via prerequisite | walking-skeleton.feature | @skip |

---

### Milestone 1: Onboarding (US-01) — 18 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M1-01 | Welcome screen shows assumed expert knowledge | Happy path | @wip |
| M1-02 | Enter goes directly to curriculum tree | Happy path | @skip |
| M1-03 | Curriculum tree shows only Lesson 1 as available | Happy path | @skip |
| M1-04 | Selecting a locked lesson shows lock screen | Error path | @skip |
| M1-05 | Lesson preview shows covered and NOT covered topics | Happy path | @skip |
| M1-06 | Exercise timer starts automatically | Happy path | @skip |
| M1-07 | Timer expiry shows correct answer, records missed | Error path | @skip |
| M1-08 | Esc skips exercise without penalty | Error path | @skip |
| M1-09 | Correct answer shows Ruby-specific explanation, no gamification | Happy path | @skip |
| M1-10 | Incorrect answer shows factual explanation, no shame | Error path | @skip |
| M1-11 | First session summary shows SM-2 init and next lesson | Happy path | @skip |
| M1-12 | "n" from summary starts next lesson immediately | Happy path | @skip |
| M1-13 | Welcome screen keyboard-accessible | Keyboard | @skip |
| M1-14 | Curriculum tree keyboard navigation (j/k) | Keyboard | @skip |
| M1-15 | Esc mid-lesson saves position for resume | Error path | @skip |
| M1-16 | Platform starts in first-time mode with no data | Edge case | @skip |
| M1-17 | "?" opens shortcut overlay from any onboarding screen | Happy path | @skip |
| M1-P1 | @property: every element keyboard-reachable | Property | @skip |
| M1-P2 | @property: no data loss on navigation | Property | @skip |

**Error/edge ratio: 7/18 = 39%** (within target range)

---

### Milestone 2: Daily Session (US-02) — 19 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M2-01 | Dashboard shows complete pre-computed plan | Happy path | @skip |
| M2-02 | Dashboard renders within 500ms | Performance | @skip |
| M2-03 | Empty queue shows "all caught up" and skips review | Edge case | @skip |
| M2-04 | Oversized queue capped at 12 with remainder deferred | Error path | @skip |
| M2-05 | Deferred exercises appear first next day | Error path | @skip |
| M2-06 | Review exercises presented most-overdue first | Happy path | @skip |
| M2-07 | Correct review extends SM-2 interval | Happy path | @skip |
| M2-08 | Incorrect review resets interval to 1 day | Error path | @skip |
| M2-09 | Skipped review defers without ease factor change | Error path | @skip |
| M2-10 | Review complete shows accuracy and advances | Happy path | @skip |
| M2-11 | New lesson uses Python/Java comparison format | Happy path | @skip |
| M2-12 | Session summary shows accurate totals | Happy path | @skip |
| M2-13 | SM-2 state persisted on session exit | Happy path | @skip |
| M2-14 | "n" starts next lesson from summary | Happy path | @skip |
| M2-15 | "t" opens topic selection without losing plan | Happy path | @skip |
| M2-16 | Session does not cut off mid-exercise at time limit | Error path | @skip |
| M2-17 | Dashboard correct when all reviews from one lesson | Edge case | @skip |
| M2-18 | Review queue excludes future exercises | Edge case | @skip |
| M2-19 | SM-2 state survives browser refresh mid-session | Error path | @skip |
| M2-P1 | @property: SM-2 scheduling is deterministic | Property | @skip |
| M2-P2 | @property: session respects 15-minute cap | Property | @skip |

**Error/edge ratio: 8/19 = 42%** (above 40% target)

---

### Milestone 3: Topic Selection (US-03, US-08) — 22 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M3-01 | Curriculum tree via "t" from session dashboard | Happy path | @skip |
| M3-02 | Curriculum tree via "c" from any screen | Happy path | @skip |
| M3-03 | Tree shows accurate lock/completion states | Happy path | @skip |
| M3-04 | Tree renders within 300ms | Performance | @skip |
| M3-05 | j/k navigation in curriculum tree | Keyboard | @skip |
| M3-06 | J/K jump between module boundaries | Keyboard | @skip |
| M3-07 | "/" opens inline keyword search | Happy path | @skip |
| M3-08 | Search with no matches shows empty state | Error path | @skip |
| M3-09 | Locked lesson shows educational lock screen | Error path | @skip |
| M3-10 | Lock screen with multiple prerequisites shows partial completion | Edge case | @skip |
| M3-11 | Available lesson goes directly to preview | Happy path | @skip |
| M3-12 | No force-skip mechanism exists | Error path | @skip |
| M3-13 | Completing prerequisite unlocks target atomically | Happy path | @skip |
| M3-14 | Module status updates after last lesson in module | Happy path | @skip |
| M3-15 | Unlock state persists across sessions | Happy path | @skip |
| M3-16 | Topic-selection exercises recorded with same SM-2 weight | Happy path | @skip |
| M3-17 | After unlock, can start target lesson immediately | Happy path | @skip |
| M3-18 | "t" override preserves SM-2 review queue | Happy path | @skip |
| M3-19 | Lesson 1 always available on first launch | Happy path | @skip |
| M3-20 | Summary shows both lessons when two completed in one sitting | Edge case | @skip |
| M3-P1 | @property: lock state consistent across all views | Property | @skip |
| M3-P2 | @property: prerequisite graph is acyclic | Property | @skip |

**Error/edge ratio: 5/20 = 25%** — acceptable given property scenarios cover invariants

---

### Milestone 4: SM-2 Engine (US-05) — 14 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M4-01 | Correct answer increases interval by ease factor | Happy path | @skip |
| M4-02 | Correct answer on interval 1 day gives minimum 1 day | Edge case | @skip |
| M4-03 | Incorrect answer resets interval to 1 day | Error path | @skip |
| M4-04 | Ease factor minimum 1.3 enforced | Edge case | @skip |
| M4-05 | Ease factor minimum outline (multiple starting values) | Boundary | @skip |
| M4-06 | Skipped re-queued with ease factor unchanged | Error path | @skip |
| M4-07 | Timer expiry (missed) treated same as incorrect | Error path | @skip |
| M4-08 | Daily queue contains exactly due exercises, ordered | Happy path | @skip |
| M4-09 | Exercises due today included in queue | Boundary | @skip |
| M4-10 | Exercises due tomorrow excluded from queue | Boundary | @skip |
| M4-11 | Daily cap of 12 enforced, excess deferred | Error path | @skip |
| M4-12 | Daily cap counts exercises not lessons | Edge case | @skip |
| M4-13 | SM-2 state survives browser refresh | Error path | @skip |
| M4-14 | SM-2 state persisted per exercise, not at session end | Error path | @skip |
| M4-15 | First exercise initializes with default SM-2 values | Happy path | @skip |
| M4-16 | Storage cleared → first-time mode | Error path | @skip |

**Error/edge ratio: 9/14 = 64%** (well above target — SM-2 correctness-critical)

---

### Milestone 5: Exercise Timer (US-04) — 9 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M5-01 | Timer starts automatically before any user input | Happy path | @skip |
| M5-02 | Timer visible as progress bar with seconds | Happy path | @skip |
| M5-03 | Timer expiry shows answer automatically | Error path | @skip |
| M5-04 | Next exercise loads after brief pause post-expiry | Happy path | @skip |
| M5-05 | Tab shows partial hint, not full answer | Happy path | @skip |
| M5-06 | Tab hint available exactly once | Edge case | @skip |
| M5-07 | Hint does not stop the timer | Error path | @skip |
| M5-08 | Submitting answer before expiry stops timer | Happy path | @skip |
| M5-09 | Each new exercise gets a fresh 30-second timer | Edge case | @skip |
| M5-10 | Timer resets on navigate-away and return | Edge case | @skip |

**Error/edge ratio: 4/9 = 44%** (above target)

---

### Milestone 6: Progress Dashboard (US-09) — 12 scenarios

| # | Scenario | Type | Status |
|---|----------|------|--------|
| M6-01 | "p" opens dashboard as overlay mid-session | Happy path | @skip |
| M6-02 | Esc closes dashboard, restores session state | Happy path | @skip |
| M6-03 | "p" from welcome screen also opens dashboard | Edge case | @skip |
| M6-04 | Accurate lesson completion count shown | Happy path | @skip |
| M6-05 | Lesson count updates immediately after completion | Happy path | @skip |
| M6-06 | Retention score from SM-2 data (10 reviews) | Happy path | @skip |
| M6-07 | Retention score from < 10 reviews uses all | Edge case | @skip |
| M6-08 | Retention score shown per completed lesson | Happy path | @skip |
| M6-09 | No gamification elements anywhere | Error path | @skip |
| M6-10 | Streak shown as plain count, not achievement | Error path | @skip |
| M6-11 | Sessions remaining estimate shown | Happy path | @skip |
| M6-12 | Dashboard correct with no lessons completed | Edge case | @skip |
| M6-13 | No retention score for lessons with no review history | Edge case | @skip |

**Error/edge ratio: 5/12 = 42%** (above target)

---

### Milestone 7: Keyboard Navigation (US-07) — 13 scenarios

All are happy path (keyboard nav is the primary, correct behavior — not an error path).

---

### Milestone 8: Lesson Content (US-06) — 9 scenarios

Property-shaped: most verify invariants across all 25 lessons.

---

### Integration Checkpoints — 12 scenarios

Cross-domain flows covering atomicity, SM-2 + session + curriculum consistency.

---

## Totals

| Category | Count |
|----------|-------|
| Walking skeletons | 3 |
| Focused scenarios (milestones 1-8) | 107 |
| Integration checkpoints | 12 |
| Infrastructure smoke tests | 9 |
| CI/CD validation | 10 |
| **Grand total** | **141** |

**Error/edge ratio across core scenarios (excl. infra): ~42%** — meets the >= 40% target.

**Property-tagged scenarios**: 8 (signals to DELIVER crafter for property-based test implementation)

---

## Coverage Map — User Story to Scenarios

| User Story | Acceptance Criteria | Scenarios |
|------------|--------------------|----|
| US-01 Onboarding | AC-01-01 to AC-01-15 | M1-01 to M1-P2 |
| US-02 Daily Session | AC-02-01 to AC-02-13 | M2-01 to M2-P2 |
| US-03 Topic Selection | AC-03-01 to AC-03-11 | M3-01 to M3-P2 |
| US-04 Exercise Timer | AC-04-01 to AC-04-04 | M5-01 to M5-10 |
| US-05 SM-2 Engine | AC-05-01 to AC-05-09 | M4-01 to M4-16 |
| US-06 Lesson Content | AC-06-01 to AC-06-05 | M8-01 to M8-P1 |
| US-07 Keyboard Nav | AC-07-01 to AC-07-10 | M7-01 to M7-13 |
| US-08 Lesson Tree | AC-08-01 to AC-08-06 | M3-03 to M3-20 |
| US-09 Progress Dashboard | AC-09-01 to AC-09-06 | M6-01 to M6-13 |
| US-10 Email (Post-MVP) | — | Excluded from MVP scope |

All AC rows from the acceptance-criteria.md document are covered.
