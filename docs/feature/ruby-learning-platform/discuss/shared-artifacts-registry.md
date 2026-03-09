# Shared Artifacts Registry — Ruby Learning Platform

## Purpose

Every data value that appears in multiple places across the user journeys is registered here with a single source of truth, its consumers, and its integration risk. Untracked shared artifacts are the primary cause of horizontal integration failures.

---

## Registry

### curriculum_structure

```yaml
source_of_truth: "db/curriculum/lessons.yml"
description: "The 25-lesson curriculum organized into 5 modules with titles and metadata"
consumers:
  - "Onboarding Step 2: curriculum tree initial render"
  - "Topic Selection Step 1: curriculum tree navigation"
  - "Daily Session Step 5: lesson content render"
  - "Lesson Tree navigation journey"
owner: "curriculum module"
integration_risk: "HIGH — if lessons.yml schema changes, all three journeys break"
validation: "All journey views must use the same lessons.yml schema version"
```

### lesson_status

```yaml
source_of_truth: "db/progress/user_progress (per lesson: not_started / complete / locked)"
description: "Whether each lesson is complete, available, or locked for the current user"
consumers:
  - "Onboarding Step 2: [ ] / [x] / [~] icons"
  - "Topic Selection Step 1: curriculum tree status icons and module status"
  - "Topic Selection Step 2: lock screen prerequisite completion flags"
  - "Topic Selection Step 5: unlock notification"
  - "Progress Dashboard: lessons_complete count and module progress bars"
owner: "progress_tracker module"
integration_risk: "HIGH — inconsistent status between curriculum tree and progress dashboard confuses user"
validation: "After any lesson completes, run prerequisite_resolver and update all consumers atomically"
```

### prerequisite_graph

```yaml
source_of_truth: "db/curriculum/prerequisites.yml"
description: "Directed acyclic graph of lesson prerequisites (lesson -> list of required lessons)"
consumers:
  - "Onboarding Step 2: inline prerequisite labels (needs L1)"
  - "Topic Selection Step 1: inline prerequisite labels in curriculum tree"
  - "Topic Selection Step 2: lock screen prerequisite detail"
  - "Session Dashboard Step 1: next_lesson resolver"
  - "Progress Dashboard: what-unlocks-next indicators"
owner: "curriculum module"
integration_risk: "HIGH — inline labels in curriculum tree must match lock screen detail exactly"
validation: >
  Run consistency check: for each locked lesson, inline label prerequisites
  must be the same set as those listed on the lock screen.
  Graph must be acyclic (no lesson can be its own prerequisite chain).
```

### next_lesson_title

```yaml
source_of_truth: "prerequisite_resolver (function: given current_progress, returns next available lesson)"
description: "The lesson that SM-2 recommends as the next new lesson to study"
consumers:
  - "Onboarding Step 6: summary 'Next session: Lesson N'"
  - "Daily Session Step 1: 'New lesson: Lesson N' in session plan"
  - "Daily Session Step 7: lesson content header"
  - "Daily Session Step 9 (session complete): 'Next session: Module X, Lesson N'"
owner: "session_planner module (calls prerequisite_resolver)"
integration_risk: "HIGH — if session_planner and session_complete use different resolvers, shown lesson differs"
validation: >
  Both session start (Step 1) and session complete (Step 9) must call
  the same prerequisite_resolver function with the same input state.
  After lesson completion, state must be updated before resolver is called for summary.
```

### review_queue_count

```yaml
source_of_truth: "sm2_engine (compute_due_today: returns count of exercises with next_review_date <= today)"
description: "Number of SM-2 exercises scheduled for review in today's session"
consumers:
  - "Daily Session Step 1: 'Review queue: N exercises'"
  - "Daily Session Step 4: 'Review complete: N exercises done'"
  - "Daily Session Step 9 (session complete): total exercises breakdown"
owner: "sm2_engine module"
integration_risk: "MEDIUM — count must be consistent from session start to session complete"
validation: >
  compute_due_today must be called once at session start and the result cached
  for the session duration. Must not recompute mid-session (would change count).
```

### sm2_next_interval

```yaml
source_of_truth: "sm2_engine (compute_next_interval: given answer quality and current ease_factor)"
description: "The number of days until an exercise should next be reviewed"
consumers:
  - "Daily Session Step 3: 'Next review in: N days' on review feedback"
  - "Onboarding Step 6: 'SM-2 will schedule reviews' (indirect)"
owner: "sm2_engine module"
integration_risk: "MEDIUM — must display computed value, not a hardcoded estimate"
validation: "Displayed interval must match the interval actually stored for that exercise's next_review_date"
```

### lesson_content

```yaml
source_of_truth: "db/curriculum/lessons.yml (fields: python_equivalent, ruby_form, explanation, exercises)"
description: "The teaching content for each lesson including comparison format and exercises"
consumers:
  - "Onboarding Steps 4-5: lesson exercises and feedback"
  - "Daily Session Steps 7-8: new lesson content and exercises"
  - "Topic Selection Steps 3-4 and 6: prerequisite lesson and target lesson"
owner: "curriculum module"
integration_risk: "MEDIUM — same lesson rendered via different entry paths must show identical content"
validation: "Lesson content must be loaded from same source regardless of navigation path (daily/onboarding/topic-select)"
```

### streak_days

```yaml
source_of_truth: "progress_tracker (consecutive_session_days: count of days with >= 1 completed session)"
description: "Count of consecutive days the user has completed at least one session"
consumers:
  - "Daily Session Step 9 (session complete): 'Streak: N days'"
owner: "progress_tracker module"
integration_risk: "LOW — display-only, no cross-journey consistency requirement"
validation: "Increment after session data is persisted, not before"
```

### module_progress

```yaml
source_of_truth: "progress_tracker (per module: lessons_complete / total_lessons)"
description: "Per-module completion percentage derived from lesson_status"
consumers:
  - "Daily Session Step 9 (session complete): 'Module 1 progress: 5/5 lessons complete'"
  - "Progress Dashboard: module progress bars"
owner: "progress_tracker module (derived from lesson_status)"
integration_risk: "MEDIUM — must derive from lesson_status, not a separate counter"
validation: "module_progress computation must use the same lesson_status source as curriculum tree"
```

### timer_remaining

```yaml
source_of_truth: "session/exercise_timer (30-second countdown per exercise)"
description: "The remaining time for the current exercise"
consumers:
  - "Onboarding Step 4: exercise timer progress bar"
  - "Daily Session Step 2: review exercise timer progress bar"
  - "Daily Session Step 5 (lesson exercise): exercise timer progress bar"
  - "Topic Selection Steps 4 and 6: exercise timers"
owner: "session module"
integration_risk: "LOW — per-exercise, does not cross steps"
validation: "Timer must start on exercise render, not on first keypress. Hard 30-second cap for all exercise types."
```

### exercise_count

```yaml
source_of_truth: "db/curriculum/exercises.yml (count of exercises per lesson)"
description: "Number of exercises in a lesson"
consumers:
  - "Onboarding Step 3: lesson preview '3 exercises'"
  - "Onboarding Step 4: progress indicator 'Exercise 1 of 3'"
  - "Onboarding Step 6: summary '3 exercises'"
owner: "curriculum module"
integration_risk: "LOW — same source, no drift risk if loaded consistently"
validation: "Preview count must match actual exercise count — not an estimate"
```

### unlocked_lessons

```yaml
source_of_truth: "prerequisite_resolver (run after lesson completion: returns newly available lessons)"
description: "The set of lessons that became available as a result of the most recent lesson completion"
consumers:
  - "Topic Selection Step 5: unlock notification '[*] L7 NOW AVAILABLE'"
  - "Curriculum tree (re-render after lesson complete)"
owner: "prerequisite_resolver module"
integration_risk: "HIGH — unlock must be atomic and durable before notification renders"
validation: >
  Run prerequisite_resolver atomically with lesson completion transaction.
  If transaction fails, do not render unlock screen.
  Unlock state in notification must match curriculum tree re-render.
```

---

## Integration Risk Summary

| Artifact | Risk Level | Primary Concern |
|---------|-----------|----------------|
| curriculum_structure | HIGH | Schema changes cascade to all journeys |
| lesson_status | HIGH | Inconsistency between tree and dashboard |
| prerequisite_graph | HIGH | Inline label vs. lock screen mismatch |
| next_lesson_title | HIGH | Different resolvers used in different views |
| unlocked_lessons | HIGH | Unlock must be atomic with lesson completion |
| review_queue_count | MEDIUM | Mid-session recompute changes count |
| sm2_next_interval | MEDIUM | Display value must match stored value |
| lesson_content | MEDIUM | Same content via different paths |
| module_progress | MEDIUM | Must derive from lesson_status not separate counter |
| streak_days | LOW | Increment timing |
| timer_remaining | LOW | Per-exercise, no cross-step risk |
| exercise_count | LOW | Same source, low drift risk |

---

## Consistency Checkpoints

These checkpoints must pass before any feature handoff to the DESIGN wave:

1. **Prerequisite graph consistency**: inline labels in curriculum tree = lock screen detail (same source)
2. **Lesson status consistency**: same lesson_status value shown in tree, lock screen, dashboard, unlock notification
3. **Next lesson resolver consistency**: session start Step 1 and session complete Step 9 call same function with same state
4. **SM-2 interval consistency**: interval displayed in feedback = interval stored as next_review_date
5. **Unlock atomicity**: unlocked_lessons set is computed in same transaction as lesson completion persist
6. **Exercise count consistency**: preview count = actual exercise count (no estimation gap)
