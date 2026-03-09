# Journey: Daily Session — Visual Map

## Persona
**Ana Folau**, 2 weeks into daily practice. Has completed Lessons 1-4. Has 6 exercises in SM-2 review queue. It is 8:45 AM, 15 minutes before standup. She opens the platform expecting it to know what she needs today.

## Goal
Ana completes her full daily session — review queue plus one new lesson — within 15 minutes, without making a single decision about what to study.

## Emotional Arc
**Start**: Trusting + Ready (the tool will tell me what to do)
**Middle**: Focused + Flowing (quick feedback loop, no dead time)
**End**: Accomplished + Complete (done in time, retention growing)

---

## Journey Flow

```
[Trigger: Ana opens the platform. It is 8:45 AM.]
    |
    | TRUSTING — "I wonder what today's queue looks like"
    v
+------------------------------------------------------------------+
| STEP 1: Session Dashboard — Today's Overview                      |
| Ana immediately sees today's plan. No navigation required.        |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Good morning. Today's session:                             |  |
|  |                                                            |  |
|  |  Review queue:  6 exercises  (~3 min)                     |  |
|  |  New lesson:    Lesson 5: Array Methods  (~4 min)         |  |
|  |                                                            |  |
|  |  Total: ~7 minutes                                         |  |
|  |                                                            |  |
|  | [Enter] Start session  [t] Select different topic          |  |
|  | [p] Progress dashboard  [?] Help                          |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | READY — "7 minutes, I have time"
    v
+------------------------------------------------------------------+
| STEP 2: Review Queue — Exercise 1 of 6                            |
| SM-2 presents exercises in order of urgency (most overdue first)  |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Review  1/6  |  [========                    ] 8s          |  |
|  |                                                            |  |
|  | Lesson 2 — String Interpolation                           |  |
|  |                                                            |  |
|  | What symbol is used for string interpolation in Ruby?      |  |
|  |                                                            |  |
|  | > _                                                        |  |
|  |                                                            |  |
|  | [Enter] Submit  [Tab] Hint  [Esc] Skip                    |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | FOCUSED — "I know this one"
    v
+------------------------------------------------------------------+
| STEP 3: Review Feedback — Correct                                 |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Correct.  #{expression}                                    |  |
|  |                                                            |  |
|  | Next review in: 4 days                                     |  |
|  |                                                            |  |
|  | [Enter] Next                                               |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    v
+------------------------------------------------------------------+
| STEP 4: Review Queue — Exercise 3 of 6 (harder one)               |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Review  3/6  |  [========                    ] 12s         |  |
|  |                                                            |  |
|  | Lesson 3 — Symbols                                        |  |
|  |                                                            |  |
|  | What is the difference between :name and "name" in Ruby?   |  |
|  |                                                            |  |
|  | > _                                                        |  |
|  |                                                            |  |
|  | [Enter] Submit  [Tab] Hint  [Esc] Skip                    |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | CONCENTRATING — "Symbols... immutable, unique, memory-efficient"
    v
+------------------------------------------------------------------+
| STEP 5: Review Feedback — Incorrect / Partial                     |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Partially correct.                                         |  |
|  |                                                            |  |
|  | :name is a Symbol — immutable, interned (one object per    |  |
|  | name in the VM), compared by identity not value.           |  |
|  | "name" is a String — mutable, creates new object each time.|  |
|  |                                                            |  |
|  | Next review: tomorrow (SM-2 reset interval)               |  |
|  |                                                            |  |
|  | [Enter] Next                                               |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | INFORMED — "I need to practice this one more"
    v
+------------------------------------------------------------------+
| STEP 6: Review Queue Complete — Transition to Lesson              |
| Short separator between review and new content                    |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Review complete.  6 exercises done.                        |  |
|  |                                                            |  |
|  |  Correct:  5/6   (83%)                                    |  |
|  |  Next review session: tomorrow (~5 exercises scheduled)    |  |
|  |                                                            |  |
|  | [Enter] Continue to Lesson 5                              |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | TRANSITIONING — "Good, now the new content"
    v
+------------------------------------------------------------------+
| STEP 7: New Lesson — Lesson 5: Array Methods                      |
| Teaching segment with active exercises embedded                   |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Lesson 5: Array Methods            Module 1/5  |  3 left   |  |
|  |                                                            |  |
|  | In Python, you iterate with list comprehensions:           |  |
|  |   [x * 2 for x in items]                                  |  |
|  |                                                            |  |
|  | In Ruby, you chain Enumerable methods:                     |  |
|  |   items.map { |x| x * 2 }                                 |  |
|  |                                                            |  |
|  | Ruby's approach: object-oriented, chainable, block-based.  |  |
|  |                                                            |  |
|  | [Enter] Try it  [Esc] Back                                 |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | LEARNING — "So map is their list comprehension"
    v
+------------------------------------------------------------------+
| STEP 8: Lesson Exercise                                           |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Exercise  1/3  |  Lesson 5  |  [=======              ] 20s |  |
|  |                                                            |  |
|  | Translate to Ruby:                                         |  |
|  |   doubled = [x * 2 for x in [1, 2, 3]]  # Python         |  |
|  |                                                            |  |
|  | > _                                                        |  |
|  |                                                            |  |
|  | [Enter] Submit  [Tab] Hint  [Esc] Skip                    |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    v
+------------------------------------------------------------------+
| STEP 9: Session Complete                                          |
|                                                                   |
|  +------------------------------------------------------------+  |
|  | Session complete.                                          |  |
|  |                                                            |  |
|  |  Today:   6 reviews + 3 new exercises  |  ~7 min          |  |
|  |  Streak:  14 days                                          |  |
|  |                                                            |  |
|  |  Module 1 progress:  5/5 lessons complete                  |  |
|  |  Next session:       Module 2, Lesson 6: Method Definition |  |
|  |  Review queue:       ~5 exercises tomorrow                 |  |
|  |                                                            |  |
|  | [Enter] Done  [p] Full progress  [n] Start Lesson 6 now   |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
    |
    | ACCOMPLISHED — "Done. In time. And I know what tomorrow looks like."
    v
[End: Session complete. SM-2 updated. Next session pre-scheduled.]
```

---

## Emotional Arc Annotations

| Step | Emotional State | Design Lever |
|------|----------------|-------------|
| Step 1 | Trusting → Ready | Session overview pre-computed; no decisions required |
| Steps 2-5 | Focused → Flowing | Fast feedback loop; 30-second cap prevents stalling |
| Step 5 | Informed (partial credit) | Feedback precise; no shame, just information |
| Step 6 | Transitioning | Explicit separator marks review-to-lesson boundary |
| Steps 7-8 | Learning → Active | Content immediately turns into exercise |
| Step 9 | Accomplished | Session totals visible; next session already defined |

---

## Error Paths and Edge Cases

### Edge Case 1: Review queue has 0 exercises
- Ana is ahead of schedule; SM-2 has nothing due today
- Step 1 shows: "Review queue: 0 exercises (all caught up)"
- Session goes directly to new lesson
- Step 9 shows clean completion without review stats

### Edge Case 2: Review queue has >15 exercises
- Ana missed 3 days; SM-2 has 18 exercises due
- Step 1 shows: "Review queue: 18 exercises (~9 min). Today's session will cover 12; 6 will carry to tomorrow."
- System caps daily review at a reasonable load (12 exercises or 6 minutes, whichever comes first)
- Deferred exercises are still high-priority for next session

### Edge Case 3: No new lesson available (all lessons complete)
- Ana has finished all 25 lessons
- Step 1 shows: "Review queue: 8 exercises. No new lessons remaining — curriculum complete."
- Session is review-only; session complete screen shows curriculum completion message

### Edge Case 4: User selects [t] to override topic on the session screen
- Pressing [t] on Step 1 opens topic selection overlay
- SM-2 queue is preserved; the selected topic replaces the system-recommended new lesson
- Session proceeds normally with the manually selected lesson

### Edge Case 5: Session timer reaches 15 minutes
- Ana was slow on some exercises; 15 minutes has elapsed
- If mid-exercise: complete the current exercise, then show session summary
- System never cuts off mid-answer
- Summary notes: "Session ended at time limit. 2 remaining review exercises carried to tomorrow."

---

## Shared Artifacts (tracked)

| Artifact | Source | Displayed At |
|---------|--------|--------------|
| `${review_queue_count}` | SM-2 engine | Steps 1, 6, 9 |
| `${review_queue_time_estimate}` | SM-2 engine (count x 30s) | Steps 1, 6 |
| `${next_lesson_title}` | Prerequisite graph resolver | Steps 1, 7, 9 |
| `${next_lesson_module}` | Lesson metadata DB | Steps 7, 9 |
| `${lesson_duration}` | Exercise count x 60s + reading | Steps 1, 9 |
| `${session_correct_count}` | Session runtime | Steps 6, 9 |
| `${session_total_count}` | Session runtime | Steps 6, 9 |
| `${streak_days}` | Progress tracker | Step 9 |
| `${sm2_next_interval}` | SM-2 engine | Steps 3, 5 |
| `${module_progress}` | Progress tracker | Step 9 |
