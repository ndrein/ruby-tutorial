# Journey Map: Topic Selection / Curriculum Navigation — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Journey**: Topic Selection (exploring curriculum → understanding progress → selecting next lesson)
**Primary Job Story**: JS-1 (Syntax Transfer) + JS-5 (Progress Visibility)
**Emotional Arc**: Curiosity → Orientation → Agency → Anticipation
**Date**: 2026-03-09

---

## Journey Overview

Marcus Chen is two weeks into daily practice. He is curious about what comes next in
the curriculum and wants to understand the full arc — how the 25 lessons connect, what
he has mastered, what is still ahead. He navigates to the curriculum view, sees his
progress through the 5 modules, understands the prerequisite structure, selects
Lesson 9 (Method Objects), and feels oriented and motivated for the next two weeks.

**Goal**: Marcus understands exactly where he is in the learning arc and feels confident
about what comes next without being overwhelmed by the full 25-lesson scope.

---

## Journey Map Table

| Step | Action | Touchpoint | Marcus Thinks | Marcus Feels | Pain Points | Shared Artifacts |
|------|--------|-----------|--------------|-------------|-------------|-----------------|
| 1. Dashboard Entry | Marcus navigates to progress dashboard from session summary | Dashboard view | "I want to see the full picture — where I actually am" | Curious, reflective | Dashboard as a dead end (no next action) | `${streak_count}`, `${mastered_count}`, `${retention_rate}` |
| 2. Mastery Overview | Reads mastery counts | Dashboard metrics panel | "24 concepts, 12 mastered, 8 in review, 4 new. That feels real." | Oriented, grounded | Abstract numbers without context feel hollow | `${mastered_count}`, `${in_review_count}`, `${new_count}` |
| 3. Retention Rate | Reads retention rate | Dashboard metrics panel | "73% retention rate. Solid. SM-2 is working." | Trusting system, slight pride | Unclear calculation method creates distrust | `${retention_rate}` |
| 4. Curriculum Map | Marcus navigates to full curriculum view | Curriculum overview — 5 modules, 25 lessons with status indicators | "I can see exactly where I am: Lesson 8 done, Lesson 9 next" | Oriented, sense of position in arc | Module walls (can't see inside a module) | `${lesson_id}`, `${lesson_status}`, `${curriculum_list}` |
| 5. Prerequisite Gate | Marcus tries to jump to Lesson 15 | Lesson 15 detail view — shows "Requires Lessons 11-14" | "Makes sense — I need the module 3 foundation first" | Accepting gate, motivated to progress | Opaque gating without rationale feels arbitrary | `${prerequisite_ids}`, `${lesson_status}` |
| 6. Lesson Details | Marcus reads Lesson 9 details | Lesson preview card — shows topic, estimated time, exercise type, Python/Java concept mapped | "Method objects. `&method(:name)`. This is what I'm missing right now." | Recognition, relevance confirmed | Lesson card too thin = no basis for selection | `${lesson_id}`, `${lesson_content}` |
| 7. Lesson Selection | Marcus selects Lesson 9 for tomorrow | "Add to queue" or "Study next" action | "This is exactly what I want for tomorrow. Done." | Agency, anticipation | Forced order removes agency | `${lesson_id}`, `${review_queue}` |
| 8. Module Progress | Marcus views Module 2 progress bar | Module 2: Ruby Methods and Blocks — 3/5 complete | "3 of 5 lessons in Module 2 done. 2 to go. I'll finish this module this week." | Motivated by proximate goal | No visible module-level progress = lost in the curriculum | `${module_id}`, `${module_progress}` |
| 9. Full Arc Anticipation | Marcus sees Module 4 (Idioms) and Module 5 (Standard Library) ahead | Curriculum map scrolled forward | "Pattern matching in Module 4. That's the modern Ruby I want. Worth the journey." | Anticipation, long-horizon motivation | Too-long curriculum feels overwhelming | `${curriculum_list}` |
| 10. Return to Dashboard | Marcus returns to dashboard | Dashboard view | "I know where I am. I know what's next. That's all I needed." | Satisfied, grounded, motivated | — | `${streak_count}`, `${mastered_count}` |

---

## Emotional Arc Visualization

```
Curiosity    Orientation    Agency    Anticipation
   |              |            |           |
   v              v            v           v
 [1]  -->  [2][3][4][5]  --> [6][7]  --> [8][9][10]


    CURIOUS                                         ANTICIPATING
    +----------------------------------------------------------+
    |                                                          |
    |  .        ___________                        ___________.|
    | . .      /           \        ______________/            |
    |.   .    /  ORIENTATION \     /  AGENCY &                 |
    |     .  /    (dashboard  \   /   SELECTION                |
    |      \/     + curriculum)\__/                            |
    |                                                          |
    +--+--+--+--+--+--+--+--+--+--+--------------------------+
       1  2  3  4  5           6  7  8  9  10
```

---

## TUI Mockups

### Step 1-3: Progress Dashboard

```
+----------------------------------------------------------+
|  RubyFlow — Dashboard                                    |
|                                                          |
|  Marcus Chen                           Streak: 14 days   |
|                                                          |
|  Progress Overview                                       |
|  -----------------                                       |
|  Mastered:    12 concepts  [############        ]  48%   |
|  In Review:    8 concepts  [########            ]        |
|  New:          4 concepts  [####                ]        |
|  Remaining:    1 concept                                 |
|                                                          |
|  Retention Rate: 73%                                     |
|  (Correct answers on SM-2 reviews, last 14 days)         |
|                                                          |
|  Lessons Complete:  8 of 25  [========            ] 32%  |
|                                                          |
|  [ View Curriculum ]  (c)    [ Start Today's Session ] (s)|
+----------------------------------------------------------+
```

### Step 4: Curriculum Overview

```
+----------------------------------------------------------+
|  RubyFlow — Curriculum Map                               |
|                                                          |
|  Module 1: Ruby Fundamentals for Polyglots   [5/5] DONE  |
|  +-- Lesson 1: Ruby Blocks                   [x] Mastered|
|  +-- Lesson 2: Symbols vs Strings            [x] Mastered|
|  +-- Lesson 3: Procs vs Lambdas              [~] Review  |
|  +-- Lesson 4: Ranges and methods            [~] Review  |
|  +-- Lesson 5: Array methods (map/select)    [~] Review  |
|                                                          |
|  Module 2: Ruby Methods and Blocks           [3/5]       |
|  +-- Lesson 6: Method definitions, kwargs    [x] Mastered|
|  +-- Lesson 7: Blocks — do...end vs {}       [x] Mastered|
|  +-- Lesson 8: Procs and lambdas — `->` syn. [~] Review  |
|  +-- Lesson 9: Method objects, &method(:n)   [>] NEXT    |
|  +-- Lesson 10: Enumerable — the key module  [ ] Locked  |
|                                                          |
|  Module 3: Ruby Object Model                 [0/5] Locked |
|  ...                                                     |
|                                                          |
|  j/k: navigate  |  Enter: lesson detail  |  c: back     |
+----------------------------------------------------------+
```

### Step 5: Prerequisite Gate (Lesson 15)

```
+----------------------------------------------------------+
|  Lesson 15: method_missing and respond_to_missing?       |
|                                                          |
|  Module 3: Ruby Object Model                             |
|  Estimated time: ~4 minutes                              |
|                                                          |
|  STATUS: LOCKED                                          |
|                                                          |
|  Requires completion of:                                 |
|    [x] Lesson 11: Classes — Ruby vs Java                 |
|    [ ] Lesson 12: Modules and mixins         (not done)  |
|    [ ] Lesson 13: attr_accessor variants     (not done)  |
|    [ ] Lesson 14: self in Ruby               (not done)  |
|                                                          |
|  Complete lessons 12-14 first.                           |
|  Estimated: 3 daily sessions to unlock.                  |
|                                                          |
|  [ Back to Curriculum ]  (Esc)                           |
+----------------------------------------------------------+
```

### Step 6: Lesson 9 Detail Card

```
+----------------------------------------------------------+
|  Lesson 9: Method Objects and &method(:name)             |
|                                                          |
|  Module 2: Ruby Methods and Blocks   |  ~4 min           |
|  Status: NEXT (available now)                            |
|                                                          |
|  What you will learn:                                    |
|    Method objects in Ruby — turning methods into values  |
|    The &method(:name) shorthand for method references    |
|                                                          |
|  Python equivalent: functools, partial, direct reference |
|  Java equivalent:   Method references (::)               |
|                                                          |
|  Exercise type: Fill-in-the-blank (30 sec)               |
|  Example: arr.map(&method(:double))                      |
|                                                          |
|  [ Study Next Session ]  (Enter)  [ Back ]  (Esc)        |
+----------------------------------------------------------+
```

### Step 8: Module Progress

```
+----------------------------------------------------------+
|  Module 2: Ruby Methods and Blocks                       |
|                                                          |
|  Progress: 3 of 5 lessons complete                       |
|  [=================>              ] 60%                  |
|                                                          |
|  Lesson 6   Definitions & kwargs     Mastered            |
|  Lesson 7   Blocks — do vs {}        Mastered            |
|  Lesson 8   Procs and lambdas        In Review           |
|  Lesson 9   Method objects           > NEXT              |
|  Lesson 10  Enumerable               Locked              |
|                                                          |
|  Completing lesson 9 unlocks Enumerable.                 |
|  Enumerable unlocks Module 3.                            |
|                                                          |
|  [ Back to full curriculum ]  (Esc)                      |
+----------------------------------------------------------+
```

---

## Integration Checkpoints

| Checkpoint | What Must Be True | Risk if Wrong |
|-----------|------------------|---------------|
| lesson_status reflects SM-2 state | A concept's status (Mastered/In Review/New) must derive from SM-2 interval data | Curriculum shows "Mastered" for a concept SM-2 has scheduled for re-review |
| prerequisite_ids gate lesson access | Lesson availability must check prerequisite completion in real time | Locked lesson shows as available; Marcus reads content before he has the foundation |
| module_progress rolls up from lesson_status | Module progress % must recalculate when lesson status changes | Module shows 60% but Marcus has completed 5/5 lessons |
| queue update from lesson selection | When Marcus selects "Study next session", lesson_id is added to next session queue | Lesson does not appear in tomorrow's session |
| retention_rate calculation visible | Dashboard shows formula or description of retention_rate calculation | Marcus sees 73% but cannot interpret or trust it |

---

## Pain Point Summary

| Step | Pain Point | Mitigation |
|------|-----------|------------|
| 2. Mastery Overview | Abstract numbers without context | Add comparative framing: "12 of 25 concepts mastered" with progress bar |
| 3. Retention Rate | Opaque metric | Plain-language description below number: "% correct on SM-2 reviews, last 14 days" |
| 5. Prerequisite Gate | Arbitrary-feeling lock | Show exactly which prerequisite lessons are needed + estimated sessions to unlock |
| 9. Full Arc | 25 lessons feels daunting | Group lessons into 5 modules; show module-level progress to create achievable milestones |
