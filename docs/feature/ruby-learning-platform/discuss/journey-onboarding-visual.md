# Journey Map: Onboarding — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Journey**: Onboarding (first visit through first SM-2 scheduling confirmation)
**Primary Job Story**: JS-1 (Syntax Transfer) + JS-2 (Daily Habit formation)
**Emotional Arc**: Skepticism → Recognition → Competence → Commitment
**Date**: 2026-03-09

---

## Journey Overview

Marcus Chen visits the platform for the first time. He has tried executeprogram.com and
been disappointed by beginner-oriented content. He is skeptical this will be different.
By the end of onboarding he has completed his first lesson, submitted his first exercise,
seen the SM-2 schedule his first review, and committed to returning tomorrow.

**Goal**: Marcus feels that this tool was built for someone exactly like him.

---

## Journey Map Table

| Step | Action | Touchpoint | Marcus Thinks | Marcus Feels | Pain Points | Shared Artifacts |
|------|--------|-----------|--------------|-------------|-------------|-----------------|
| 1. Arrival | Visits landing page | Landing page / UVP headline | "OK, 'Ruby for people who already know how to program' — I've heard this before" | Skeptical, cautiously curious | Cynicism from past tool disappointments | — |
| 2. Curriculum Preview | Reads lesson list | Curriculum overview page | "Wait, lesson 1 is blocks and procs — not variables? This is different" | Surprised, interest rising | No pain here — this is the recognition moment | `${curriculum_list}` |
| 3. Account Creation | Registers | Sign-up form (email only) | "Minimal — good. I don't want to fill out a 10-field profile" | Relieved, frictionless | Long forms kill momentum | `${user_email}`, `${user_id}` |
| 4. Experience Confirmation | Confirms expert mode | Single question: "Do you know Python or Java?" | "Yes, finally — it's asking if I'm an expert, not treating me as a beginner by default" | Recognized, respected | Form-heavy onboarding would kill this moment | `${experience_level}` |
| 5. First Lesson | Reads Lesson 1: Blocks | Lesson view with Python/Java side-by-side | "This is exactly the framing I needed — show me how it maps to what I know" | Competent, engaged, learning | Dense lesson could lose pacing if not well-structured | `${lesson_id}`, `${lesson_content}` |
| 6. First Exercise | Types answer to fill-in-blank | Exercise input, 30-second timer visible | "Pressing Enter to submit — good. I don't need to click anything" | Focused, in flow | Timer anxiety if first exercise is too hard | `${exercise_id}`, `${timer_seconds}` |
| 7. Answer Feedback | Sees result + explanation | Feedback panel | "I got it right — and the explanation reinforces exactly why" | Satisfied, confidence building | Feedback must be informative even on correct answer | `${answer_result}`, `${explanation}` |
| 8. SM-2 Scheduling | Sees scheduling confirmation | "This concept will be reviewed in 3 days" | "The system is now tracking this for me — I don't have to remember to review it" | Relieved, trusting the system | Black-box anxiety if scheduling rationale is invisible | `${next_review_date}`, `${sm2_interval}` |
| 9. Session Summary | Sees summary screen | Session end page with time + what was covered | "4 minutes. And I learned something. I can do this every day" | Committed, proud, streak-motivated | No pain — this is the commitment moment | `${session_duration}`, `${streak_count}` |
| 10. Email Opt-in | Prompted to confirm email | Email confirmation prompt | "A daily queue email — that's exactly the habit trigger I needed" | Engaged, habit forming | Opt-in must not feel like a newsletter subscription | `${user_email}`, `${review_queue}` |

---

## Emotional Arc Visualization

```
Skepticism    Recognition    Competence    Commitment
    |               |              |             |
    v               v              v             v
  [ 1 ]  -->  [ 2 ][ 3 ][ 4 ]  [ 5 ][ 6 ][ 7 ]  [ 8 ][ 9 ][ 10 ]
   Low              Rising         Peak           Sustained


    SKEPTICAL                                           COMMITTED
    +---------------------------------------------------------+
    |                                                         |
    |    ...      /                                           |
    |   .  .     / <- Recognition                            |
    |  .    .   /    (Lesson 1 topic list)                   |
    | .      . /                                             |
    |.        X <- Competence peak                           |
    |        / \   (first exercise correct)                  |
    |       /   \_______-> Commitment plateau                |
    |      /              (SM-2 schedules review)            |
    +-----+---+---+---+---+---+---+---+---+---+-------------+
          1   2   3   4   5   6   7   8   9  10
```

---

## TUI Mockups

### Step 1: Landing Page (Arrival)

```
+----------------------------------------------------------+
|  RubyFlow                                                |
|                                                          |
|  Ruby for people who don't need Ruby explained.          |
|                                                          |
|  25 expert lessons. SM-2 spaced repetition.              |
|  15 minutes a day. Keyboard-native.                      |
|                                                          |
|  Assumes you know: Python or Java                        |
|  Skips: variables, loops, OOP basics, conditionals       |
|  Teaches: blocks, procs, symbols, Enumerable, idioms     |
|                                                          |
|  [ View Curriculum ]          [ Start Free ]             |
|    (Tab to navigate)           (Enter to confirm)        |
+----------------------------------------------------------+
```

### Step 4: Experience Confirmation

```
+----------------------------------------------------------+
|  One question before we start                            |
|                                                          |
|  Do you have experience in another programming language? |
|                                                          |
|  > [x] Yes — Python, Java, or similar                   |
|    [ ] No — I'm newer to programming                     |
|                                                          |
|  (Use j/k to select, Enter to confirm)                   |
|                                                          |
|  Note: If you select "Yes", we skip variables, OOP       |
|  basics, and control flow. Lesson 1 starts with blocks.  |
+----------------------------------------------------------+
```

### Step 5: First Lesson View

```
+----------------------------------------------------------+
|  Lesson 1 of 25 — Ruby Blocks                           |
|  [================>                  ] 4% complete        |
|                                                          |
|  RUBY BLOCKS                                             |
|                                                          |
|  In Python you use lambdas or list comprehensions.       |
|  In Java you use anonymous functions or streams.         |
|  In Ruby you use BLOCKS — code passed to a method.       |
|                                                          |
|  Python:  [x * 2 for x in lst]                          |
|  Java:    lst.stream().map(x -> x * 2)                   |
|  Ruby:    lst.map { |x| x * 2 }                         |
|                                                          |
|  Key insight: the block { |x| x * 2 } is not a value.   |
|  It is passed to the method. Methods can yield to it.    |
|                                                          |
|  [ Continue to Exercise ]  (Enter)      [ l ] Lesson map |
+----------------------------------------------------------+
```

### Step 6: First Exercise (30-second timer)

```
+----------------------------------------------------------+
|  Exercise 1.1 — Fill in the blank              [0:28]    |
|                                                          |
|  Complete the Ruby code to select even numbers:          |
|                                                          |
|  [1, 2, 3, 4].______ { |n| n.even? }                    |
|               ^^^^^^^                                    |
|  Your answer: [select_____________]                      |
|                                                          |
|  Enter: submit  |  Esc: skip  |  h: mark hard           |
|                                                          |
|  Tip: Think of Python's list comprehension with a filter |
+----------------------------------------------------------+
```

### Step 8: SM-2 Scheduling Confirmation

```
+----------------------------------------------------------+
|  Good work.                                              |
|                                                          |
|  Concept: Ruby Blocks (Lesson 1)                         |
|  Your answer: Correct                                    |
|                                                          |
|  SM-2 has scheduled your next review:                    |
|                                                          |
|    Next review: March 12 (in 3 days)                     |
|    Reason: First exposure — short interval to confirm     |
|                                                          |
|  You will see this in your daily queue on March 12.      |
|  Until then — nothing to do.                             |
|                                                          |
|  [ Continue ]  (Enter)                                   |
+----------------------------------------------------------+
```

### Step 9: Session Summary

```
+----------------------------------------------------------+
|  Session Complete                                        |
|                                                          |
|  Today's Session                                         |
|  ---------------                                         |
|  Lesson completed:  Ruby Blocks (Lesson 1 of 25)         |
|  Exercises done:    1                                    |
|  Time taken:        4 min 12 sec                         |
|  Daily target:      15 min                               |
|  Time remaining:    10 min 48 sec                        |
|                                                          |
|  Streak: 1 day  (start of something good)                |
|                                                          |
|  Tomorrow: Review Ruby Blocks + Lesson 2 option          |
|                                                          |
|  [ Go to Dashboard ]  (g d)    [ Done for today ] (Esc)  |
+----------------------------------------------------------+
```

---

## Integration Checkpoints

| Checkpoint | What Must Be True | Risk if Wrong |
|-----------|------------------|---------------|
| Experience level persists | `${experience_level}` must drive curriculum filtering throughout the app | Marcus sees beginner content after confirming expert mode = broken promise |
| SM-2 first scheduling | After first exercise, SM-2 must create an entry with correct interval (3 days default for first exposure) | Review queue will be empty or wrong on Day 3 |
| Email opt-in links to queue | `${user_email}` must link to `${review_queue}` and trigger email on day of first review | Marcus does not get the habit trigger that drives return |
| Session timer accuracy | `${session_duration}` must reflect actual elapsed time | Session summary shows wrong time; trust broken |

---

## Pain Point Summary

| Step | Pain Point | Mitigation |
|------|-----------|------------|
| 1. Arrival | "Another beginner tool" cynicism | UVP explicitly names what is skipped (variables, loops, OOP) |
| 3. Sign-up | Long forms kill momentum | Email + experience level only; no profile required |
| 5. Lesson | Dense content losing pacing | Python/Java side-by-side creates anchor; 30-second read target |
| 6. Exercise | Timer anxiety | Timer visible but not alarming; Esc to skip is always available |
| 8. SM-2 | Black-box anxiety | Plain-language scheduling explanation ("in 3 days, because: first exposure") |
