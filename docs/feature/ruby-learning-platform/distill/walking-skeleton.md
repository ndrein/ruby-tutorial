# Walking Skeleton — Ruby Learning Platform

**Date**: 2026-03-09
**Wave**: DISTILL
**Status**: Ready for DELIVER

---

## Purpose

Walking skeletons are the starting point for the DELIVER wave. Each skeleton
proves a user can accomplish a primary goal end-to-end — demo-able to a
stakeholder without technical context.

There are 3 skeletons for this feature. Implement them in order. Do not start
skeleton 2 until skeleton 1 passes. Do not start skeleton 3 until skeleton 2 passes.

---

## Skeleton 1: First Exercise (Start Here)

**File**: `tests/features/ruby-learning-platform/acceptance/walking-skeleton.feature`
**Tag**: `@walking_skeleton` (first scenario, no `@skip`)
**User goal**: Ana opens the platform, completes her first exercise, and sees her result saved.

### What this proves
- Onboarding renders without login
- Curriculum tree shows Lesson 1 as available
- Exercise timer starts and accepts an answer
- Answer feedback is returned
- SM-2 state is persisted

### Minimum slices to make it pass
1. `OnboardingController#show` — renders welcome screen
2. `LessonsController#index` — renders curriculum tree with Lesson 1 available
3. `LessonsController#show` — opens Lesson 1 preview
4. `ExercisesController#show` — renders exercise with timer
5. `ExercisesController#submit` — evaluates answer, returns feedback
6. `ReviewScheduler#record_result` — persists SM-2 state via ReviewRepository

### Driving ports exercised
- `OnboardingController` (primary adapter) → `CurriculumMap`
- `ExercisesController` (primary adapter) → `AnswerEvaluator`, `ReviewScheduler`

---

## Skeleton 2: Full Daily Session

**File**: `tests/features/ruby-learning-platform/acceptance/walking-skeleton.feature`
**Tag**: `@walking_skeleton @skip` (second scenario)
**User goal**: Ana completes a daily session with review exercises and a new lesson.

### What this proves
- `SessionPlanner` computes a plan with reviews + next lesson
- Review queue runs before the new lesson
- SM-2 intervals update correctly through the session
- Session summary shows accurate totals
- All state persisted atomically on session complete

### Enable after
Skeleton 1 passes and is committed to main.

### Minimum slices to add
1. `SessionsController#show` — session dashboard with plan
2. `ReviewQueue` — computes due exercises ordered by urgency
3. Session-to-lesson transition flow
4. `SessionsController#complete` — atomic session persistence

---

## Skeleton 3: Prerequisite Lookup and Unlock

**File**: `tests/features/ruby-learning-platform/acceptance/walking-skeleton.feature`
**Tag**: `@walking_skeleton @skip` (third scenario)
**User goal**: Ana navigates to a locked lesson, completes the prerequisite, and unlocks her target.

### What this proves
- `CurriculumMap` shows correct lock states
- `LockScreenPolicy` generates educational lock screen content
- `LessonUnlocker` runs atomically with lesson completion
- Unlock state persists across sessions

### Enable after
Skeleton 2 passes and is committed to main.

### Minimum slices to add
1. `LessonsController#show` — lock screen for locked lesson
2. `LessonUnlocker#unlock_after_completion` — atomic unlock
3. `LockScreenPolicy#content_for` — prerequisites and topics
4. Unlock notification on completion screen

---

## One-at-a-Time Implementation Sequence

After all 3 skeletons pass, proceed to focused scenarios in this order:

| Order | Feature File | First Scenario to Enable |
|-------|-------------|--------------------------|
| 4 | milestone-1-onboarding.feature | Expert calibration (welcome screen) |
| 5 | milestone-2-daily-session.feature | Session dashboard pre-computation |
| 6 | milestone-4-sm2-engine.feature | Correct answer increases interval |
| 7 | milestone-3-topic-selection.feature | Curriculum tree access via "t" |
| 8 | milestone-5-exercise-timer.feature | Timer starts automatically |
| 9 | milestone-6-progress-dashboard.feature | Dashboard access via "p" |
| 10 | milestone-7-keyboard-navigation.feature | Esc goes back from any screen |
| 11 | milestone-8-lesson-content.feature | Comparison format present |
| 12 | integration-checkpoints.feature | Cross-domain flows |

Enable one `@skip` scenario at a time. Remove `@skip`, add `@wip`, implement, commit.
Then remove `@wip` and move to the next `@skip`.
