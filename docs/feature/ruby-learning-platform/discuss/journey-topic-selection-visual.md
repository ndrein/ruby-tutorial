# Journey: Topic Selection — Visual Map

## Persona
**Ana Folau**, 3 weeks into daily practice. Has completed Module 1 (5 lessons). Currently on Module 2 Lesson 6. She has just been assigned a PR review that uses Ruby blocks heavily, and she wants to jump to Lesson 7 (Blocks and Yield) immediately rather than waiting for sequential progression.

## Goal
Ana locates Lesson 7 in the curriculum tree, understands that Lesson 6 (Method Definition) is the only prerequisite she still needs, completes Lesson 6, and unlocks Lesson 7 — or she finds that Lesson 7 is already available and jumps directly.

## Emotional Arc
**Start**: Goal-Oriented + Impatient (I need blocks NOW, for work)
**Middle**: Informed + In-Control (I see exactly what stands between me and my target)
**End**: Satisfied + Capable (I got to the topic I needed on my own terms)

---

## Journey Flow

```
[Trigger: Ana is in daily session Step 1 and presses [t] to override topic]
  OR
[Trigger: Ana opens the platform and presses [c] for curriculum view]
    |
    | IMPATIENT — "I need to get to blocks fast"
    v
+------------------------------------------------------------------+
| STEP 1: Topic Selection Entry — Curriculum Tree                   |
| Full curriculum visible. Completed = filled, locked = dimmed.    |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Curriculum  [/] Search  [j/k] Navigate  [Enter] Select    |  |
|  |                                                            |  |
|  | MODULE 1: Ruby Fundamentals                  [COMPLETE]   |  |
|  |  [x] L1  Syntax Differences                              |  |
|  |  [x] L2  String Interpolation                            |  |
|  |  [x] L3  Symbols                                         |  |
|  |  [x] L4  Ranges                                          |  |
|  |  [x] L5  Array Methods                                   |  |
|  |                                                            |  |
|  | MODULE 2: Methods and Blocks                 [IN PROGRESS] |  |
|  |  [ ] L6  Method Definition       <- NEXT (unlocked)       |  |
|  |  [~] L7  Blocks and Yield        <- LOCKED (needs L6)    |  |
|  |  [~] L8  Procs and Lambdas       <- LOCKED (needs L7)    |  |
|  |  [~] L9  Method Objects          <- LOCKED (needs L7)    |  |
|  |  [~] L10 Enumerable              <- LOCKED (needs L8,L9) |  |
|  |                                                            |  |
|  | MODULE 3: Ruby Object Model                  [LOCKED]      |  |
|  | MODULE 4: Ruby Idioms                        [LOCKED]      |  |
|  | MODULE 5: Standard Library Essentials        [LOCKED]      |  |
|  |                                                            |  |
|  | [Esc] Back to session                                      |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | ORIENTED — "I can see exactly where Lesson 7 is"
    v
+------------------------------------------------------------------+
| STEP 2: Ana navigates to Lesson 7 (locked) and presses Enter      |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | L7: Blocks and Yield                          [LOCKED]     |  |
|  |                                                            |  |
|  | Why locked:                                                |  |
|  |   Requires: L6 Method Definition (not yet complete)       |  |
|  |                                                            |  |
|  | What L7 covers:                                            |  |
|  |   - Block syntax: do...end vs { }                         |  |
|  |   - yield keyword                                         |  |
|  |   - Implicit vs explicit blocks                            |  |
|  |   - block_given? guard pattern                            |  |
|  |                                                            |  |
|  | What L6 covers (prerequisite):                             |  |
|  |   - def/end syntax                                        |  |
|  |   - Default argument values                               |  |
|  |   - Keyword arguments                                     |  |
|  |   - Return values (implicit)                              |  |
|  |                                                            |  |
|  | [Enter] Go to L6 first  [Esc] Back to curriculum           |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | INFORMED — "I see exactly what I need to do. One lesson standing in the way."
    v
+------------------------------------------------------------------+
| STEP 3: Ana presses Enter to go to Lesson 6                       |
| System navigates to Lesson 6 directly                             |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 6: Method Definition         Module 2/5  |  ~4 min  |  |
|  |                                                            |  |
|  | In Python, you define functions with def and colons.       |  |
|  | Ruby methods use def...end (like a block, not indentation) |  |
|  |                                                            |  |
|  | def greet(name, greeting: "Hello")                        |  |
|  |   "#{greeting}, #{name}!"                                 |  |
|  | end                                                        |  |
|  |                                                            |  |
|  | Key differences: keyword arguments, implicit return,       |  |
|  | no type annotations, no self-parameter in methods.         |  |
|  |                                                            |  |
|  | [Enter] Start exercises  [Esc] Back                        |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | FOCUSED — "Good, this is new enough to be worth learning"
    v
+------------------------------------------------------------------+
| STEP 4: Lesson 6 Exercises (3 exercises, ~3 min)                  |
| (same exercise flow as daily session journey)                     |
|                                                                   |
|    [Exercise 1] -> [Feedback] -> [Exercise 2] -> [Feedback]       |
|                 -> [Exercise 3] -> [Feedback]                     |
|                                                                   |
+------------------------------------------------------------------+
    |
    | ACCOMPLISHED — "Lesson 6 done"
    v
+------------------------------------------------------------------+
| STEP 5: Lesson 6 Complete — Lesson 7 Now Unlocked                 |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 6 complete.                                         |  |
|  |                                                            |  |
|  | Unlocked:                                                  |  |
|  |   [*] L7  Blocks and Yield     <- NOW AVAILABLE           |  |
|  |                                                            |  |
|  | [Enter] Start Lesson 7 now  [Esc] Save for next session   |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | MOTIVATED — "Right, this is what I actually came for"
    v
+------------------------------------------------------------------+
| STEP 6: Lesson 7 — Blocks and Yield                               |
| Ana now completes the lesson she actually needed for work          |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 7: Blocks and Yield           Module 2/5  |  ~5 min |  |
|  |                                                            |  |
|  | In Python, you pass callables (lambdas, functions).        |  |
|  | In Ruby, you pass blocks — anonymous code chunks.          |  |
|  |                                                            |  |
|  | def run_twice                                              |  |
|  |   yield                                                    |  |
|  |   yield                                                    |  |
|  | end                                                        |  |
|  |                                                            |  |
|  | run_twice { puts "hello" }  #=> hello\nhello               |  |
|  |                                                            |  |
|  | [Enter] Start exercises  [Esc] Back                        |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | CAPABLE — "Now I can review that PR"
    v
[End: Ana has the blocks knowledge she needed. Session ran ~14 min.
 SM-2 records both L6 and L7 exercises.]
```

---

## Emotional Arc Annotations

| Step | Emotional State | Design Lever |
|------|----------------|-------------|
| Step 1 | Impatient → Oriented | Full tree visible immediately; visual lock/unlock states clear |
| Step 2 | Oriented → Informed | Lock screen explains WHY and shows WHAT prerequisite covers |
| Step 3 | Informed → Focused | Direct navigation to prerequisite — no extra steps |
| Steps 4 | Focused | Fast exercise loop (same as daily session) |
| Step 5 | Accomplished + Motivated | Unlock moment is explicit and celebrated |
| Step 6 | Capable | Target lesson reached; goal achieved |

---

## Error Paths and Edge Cases

### Edge Case 1: Multiple prerequisites for a locked lesson
- Ana selects Lesson 10 (Enumerable) which requires L8 and L9
- Lock screen shows: "Requires: L8 Procs/Lambdas (complete), L9 Method Objects (not complete)"
- Shows partial completion — L8 done, L9 still needed
- [Enter] navigates to L9 (the incomplete one)

### Edge Case 2: User searches for a topic by keyword
- Ana presses [/] on Step 1 and types "block"
- Filtered view shows only lessons matching "block": L7 (Blocks and Yield), L8 (Procs and Lambdas)
- Filter applied inline without navigating to new screen
- Ana can select from filtered results

### Edge Case 3: User tries to force-skip a prerequisite
- No mechanism to force-skip exists in the UI
- Lock screen does not offer a "skip anyway" option
- This is intentional: prerequisite gates are absolute, not advisory
- User can view locked lesson content in preview mode (read-only, no exercises)

### Edge Case 4: User selects a currently available (unlocked) lesson from curriculum
- Ana selects L8 which is still locked, but then presses [Esc] back to curriculum
- Ana selects L6 which IS available and presses Enter
- System navigates directly to L6 lesson start (no intermediate lock screen)

### Edge Case 5: User arrives via [t] override from daily session
- Session screen's SM-2-recommended next lesson was L6
- Ana overrides with [t], selects L7 (locked), sees lock screen, navigates to L6
- Completes L6, unlocks L7, completes L7
- Session summary shows both L6 and L7 as completed today
- SM-2 updates for both lessons

---

## Shared Artifacts (tracked)

| Artifact | Source | Displayed At |
|---------|--------|--------------|
| `${lesson_title}` | Lesson metadata DB | Steps 1, 2, 3, 5, 6 |
| `${lesson_status}` | Progress tracker | Step 1 (complete/locked/available) |
| `${prerequisite_lessons}` | Prerequisite graph | Step 2 |
| `${prerequisite_status}` | Progress tracker x prerequisite graph | Step 2 |
| `${lesson_topics}` | Lesson metadata DB | Steps 2, 3, 6 |
| `${module_name}` | Curriculum schema | Steps 1, 3, 6 |
| `${unlocked_lessons}` | Prerequisite resolver | Step 5 |
