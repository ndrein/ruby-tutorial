# Journey: First-Time Onboarding — Visual Map

## Persona
**Ana Folau**, senior Python developer, joining a Ruby-on-Rails team. Experienced with OOP, algorithms, Python idioms. Zero Ruby syntax. Needs to get productive in Ruby within 3 weeks. Values efficiency and precision; has strong negative feelings about being talked down to.

## Goal
Ana launches the learning platform for the first time, understands the curriculum structure, sees where she starts, and completes her first exercise — all within 5 minutes, without feeling like a beginner.

## Emotional Arc
**Start**: Skeptical + Impatient (another learning tool that will waste my time on basics)
**Middle**: Relieved + Engaged (this actually starts where I am)
**End**: Confident + Committed (I can do this in 15 minutes every morning)

---

## Journey Flow

```
[Trigger: First launch]
    |
    | SKEPTICAL — "Will this waste my time?"
    v
+------------------------------------------------------------------+
| STEP 1: Welcome + Calibration Signal                              |
| Ana sees the landing view. No login. No account creation.         |
| First screen immediately declares what is NOT here.               |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Ruby for Experienced Developers                            |  |
|  |                                                            |  |
|  | This tool assumes you know:                               |  |
|  |   [x] Variables and types                                 |  |
|  |   [x] OOP (classes, inheritance, interfaces)              |  |
|  |   [x] Control flow (if/else, loops, exceptions)           |  |
|  |   [x] Functions and basic data structures                 |  |
|  |                                                            |  |
|  | It teaches: Ruby-specific syntax, idioms, and patterns    |  |
|  | that differ from Python and Java.                         |  |
|  |                                                            |  |
|  | Press [Enter] to begin your first session                 |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | RELIEVED — "This is not going to explain what a variable is"
    v
+------------------------------------------------------------------+
| STEP 2: Curriculum Overview — The Lesson Tree                     |
| Ana sees the 5-module structure at a glance.                      |
| Module 1 is highlighted as available. Modules 2-5 are dimmed.    |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Curriculum — 25 Lessons across 5 Modules                  |  |
|  |                                                            |  |
|  | [Module 1: Ruby Fundamentals for Polyglots]  AVAILABLE    |  |
|  |  1 Syntax Differences       [ ] Not started               |  |
|  |  2 String Interpolation     [ ] Locked (needs L1)         |  |
|  |  3 Symbols                  [ ] Locked (needs L1)         |  |
|  |  4 Ranges                   [ ] Locked (needs L2,L3)      |  |
|  |  5 Array Methods            [ ] Locked (needs L4)         |  |
|  |                                                            |  |
|  | [Module 2: Methods and Blocks]              LOCKED         |  |
|  | [Module 3: Ruby Object Model]               LOCKED         |  |
|  | [Module 4: Ruby Idioms]                     LOCKED         |  |
|  | [Module 5: Standard Library Essentials]     LOCKED         |  |
|  |                                                            |  |
|  | [j/k] Navigate  [Enter] Start Lesson 1  [?] Help          |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | CURIOUS — "What is Lesson 1 about?"
    v
+------------------------------------------------------------------+
| STEP 3: Lesson 1 Preview — Before Starting                        |
| Ana can see what she is about to do before committing.            |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 1: Ruby Syntax Differences                          |  |
|  | Module 1 of 5  |  ~4 min  |  3 exercises                  |  |
|  |                                                            |  |
|  | What this covers:                                          |  |
|  |   - No semicolons. No type declarations.                  |  |
|  |   - def/end instead of def: and indentation               |  |
|  |   - puts vs print vs p                                     |  |
|  |   - nil vs None, true/false vs True/False                  |  |
|  |                                                            |  |
|  | What this DOES NOT cover:                                  |  |
|  |   - What variables are                                     |  |
|  |   - Control flow basics                                    |  |
|  |   - OOP fundamentals                                       |  |
|  |                                                            |  |
|  | [Enter] Start  [Esc] Back to curriculum                    |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | ENGAGED — "This is exactly what I need"
    v
+------------------------------------------------------------------+
| STEP 4: First Exercise                                            |
| 30-second hard cap. Immediate, active, not passive reading.       |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Exercise 1 of 3  |  Lesson 1  |  [========          ] 15s |  |
|  |                                                            |  |
|  | In Python you write:                                       |  |
|  |   def greet(name):                                        |  |
|  |       return f"Hello, {name}"                             |  |
|  |                                                            |  |
|  | How would you write this in Ruby?                          |  |
|  |                                                            |  |
|  | > _                                                        |  |
|  |                                                            |  |
|  | [Enter] Submit  [Tab] Hint  [Esc] Skip                    |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | FOCUSED — "I know this, let me show it"
    v
+------------------------------------------------------------------+
| STEP 5: Exercise Feedback                                         |
| Immediate, precise, no fluff.                                     |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Correct.                                                   |  |
|  |                                                            |  |
|  | def greet(name)                                           |  |
|  |   "Hello, #{name}"                                        |  |
|  | end                                                        |  |
|  |                                                            |  |
|  | Ruby's string interpolation uses #{} not f"".             |  |
|  | Implicit return means the last expression is returned.    |  |
|  | No colon after method signature. End with `end`.          |  |
|  |                                                            |  |
|  | [Enter] Next exercise  [?] See full explanation            |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | SATISFIED — "That was precise and respectful"
    v
+------------------------------------------------------------------+
| STEP 6: Session Complete — First Session Summary                  |
| End of first lesson. SM-2 initialized. Schedule set.             |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 1 complete.                                         |  |
|  |                                                            |  |
|  | Today: 3 exercises  |  1 lesson  |  ~4 minutes             |  |
|  |                                                            |  |
|  | Review queue: SM-2 will schedule these exercises           |  |
|  | for review based on your answers.                          |  |
|  |                                                            |  |
|  | Next session: Lesson 2 (String Interpolation)              |  |
|  | Estimated review queue: 2 exercises                        |  |
|  |                                                            |  |
|  | [Enter] Done  [n] Start Lesson 2 now                      |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | COMMITTED — "I know exactly what tomorrow looks like"
    v
[End: Ana has completed her first session, SM-2 initialized,
 curriculum understood, next step is clear]
```

---

## Emotional Arc Annotations

| Step | Emotional State | Design Lever |
|------|----------------|-------------|
| Step 1 | Skeptical → Relieved | Explicit "what we skip" messaging; no login friction |
| Step 2 | Relieved → Curious | Curriculum tree visible immediately; lock/unlock visual clear |
| Step 3 | Curious → Engaged | Lesson preview shows scope before commitment |
| Step 4 | Engaged → Focused | 30-second cap feels fast and respectful; active not passive |
| Step 5 | Focused → Satisfied | Feedback precise and explains the Ruby-specific reason |
| Step 6 | Satisfied → Committed | SM-2 explained; next session previewed; no ambiguity |

---

## Error Paths and Edge Cases

### Edge Case 1: User tries to navigate to a locked lesson
- Ana presses Enter on a locked lesson in Step 2
- System shows: "Lesson 4: Ranges requires Lessons 2 and 3. Complete those first."
- Shows which specific prerequisites are needed, not just "LOCKED"
- Ana presses Esc to return to curriculum tree

### Edge Case 2: User skips an exercise
- Ana does not know the answer and presses [Esc] to skip
- System marks exercise as "skipped" not "failed" for SM-2
- Skipped exercises are re-queued for the next session (not counted against retention score)
- Feedback shown with correct answer anyway

### Edge Case 3: User runs out of time mid-exercise
- 30-second timer expires
- System shows correct answer automatically ("Time — here is the answer")
- SM-2 records as "missed" and schedules aggressive early review
- Session continues to next exercise

### Edge Case 4: User tries to start Lesson 2 before Lesson 1 completes
- Lesson 2 is shown but greyed out until Step 6 completes
- Selecting it shows: "Complete Lesson 1 first. You are on exercise 2 of 3."

---

## Shared Artifacts (tracked)

| Artifact | Source | Displayed At |
|---------|--------|--------------|
| `${lesson_title}` | Lesson metadata DB | Steps 2, 3, 5, 6 |
| `${lesson_duration}` | Estimated from exercise count | Steps 3, 6 |
| `${exercise_count}` | Lesson metadata DB | Steps 3, 4, 6 |
| `${module_number}` | Curriculum schema | Steps 2, 3, 4 |
| `${next_lesson}` | Prerequisite graph resolver | Step 6 |
| `${sm2_next_review_count}` | SM-2 engine | Step 6 |
| `${timer_remaining}` | Session timer (30s cap) | Step 4 |
