# Mutation Testing Report

## Summary
- **Tool:** mutant 0.15.0
- **Operators:** light
- **Total mutants:** 1,115
- **Killed:** 1,054
- **Survived:** 61
- **Kill rate:** 94.53%
- **Threshold:** 80%
- **Result:** PASS

## Per-Service Results

| Service | Mutants | Killed | Survived | Kill Rate |
|---------|---------|--------|----------|-----------|
| SM2Engine | 203 | 185 | 18 | 91.13% |
| ScoreCalculator | 94 | 93 | 1 | 98.93% |
| SessionTracker | 189 | 182 | 7 | 96.29% |
| QueueBuilder | 143 | 139 | 4 | 97.20% |
| PrerequisiteChecker | 70 | 62 | 8 | 88.57% |
| LessonStatusProjector | 162 | 158 | 4 | 97.53% |
| CurriculumValidator | 254 | 235 | 19 | 92.51% |

## Surviving Mutants

### SM2Engine (18 survived)

**next_review_date not asserted (5 mutants):** Tests never assert `result.next_review_date`, so mutations removing, nullifying, or altering `Date.today + interval` all survive. These mutations change `next_review_date` to `nil`, `Date.today`, `interval`, or `Date.today - interval`.

**clamped_ease_factor formula constants (13 mutants):** The `(5 - input.quality)` constant can be mutated to `(1 - input.quality)` or `(4 - input.quality)` without detection because the EF clamping at [1.3, 2.5] absorbs formula changes when quality=0 (already clamped low) or quality=4/5 (already clamped high). Also, removing the inner `(5 - input.quality) * 0.02` term survives because no test uses a quality value where the quadratic term changes the result outside the clamp range. The `.round` removal on interval calculation also survives for `(6 * 2.5).round == 15` since `6 * 2.5 = 15.0` is already an integer.

### ScoreCalculator (1 survived)

**Boundary `<=` to `<` on SLOW_THRESHOLD_SECONDS:** Changing `elapsed_seconds <= SLOW_THRESHOLD_SECONDS` to `elapsed_seconds < SLOW_THRESHOLD_SECONDS` survives because no test uses the exact boundary value of 30 seconds.

### SessionTracker (7 survived)

**`streak_count + 1` to `1` (1 mutant):** Replacing `user.streak_count + 1` with literal `1` survives because the test starts from streak_count=0, so `0 + 1 == 1`.

**`already_credited_today?` weakened (1 mutant):** Replacing `user.last_session_date == Date.current` with `user.last_session_date` survives because the test sets `last_session_date` to today (truthy) and the guard returns early either way.

**`>=` to `>` on CAP boundaries (2 mutants):** Changing `elapsed_seconds >= CAP_REDIRECT_SECONDS` and `>= CAP_WARNING_SECONDS` to `>` survives because tests use 905s and 855s (not the exact boundary values 900/850).

**`exercises_completed >= 1` to `> 1` (1 mutant):** Survives because the qualification test uses exercises_completed=3, not the boundary value 1.

**Other minor mutants (2):** Internal restructuring mutants on the record_exercise method.

### QueueBuilder (4 survived)

**to_postgres_array type guard (4 mutants):** All 4 surviving mutations are on the `ArgumentError` guard in `to_postgres_array` -- removing the guard entirely, weakening the `is_a?(Integer)` check, or changing `ArgumentError` to `RuntimeError`. No test passes non-integer values, so the guard is never exercised.

### PrerequisiteChecker (8 survived)

**Early return for empty prerequisites (5 mutants):** Mutations removing the early `return true`, replacing it with `nil`, or changing `empty?` to `nil` survive because the test for "no prerequisites" creates a lesson with `prerequisite_ids = []` where `[].all?` also returns `true` (vacuously), so the early return is redundant for functional correctness.

**Other structural mutants (3):** Minor mutations to the `all?` block and `include?` call that produce equivalent behavior for the test data.

### LessonStatusProjector (4 survived)

**`exercises.empty?` branch (2 mutants):** Replacing `exercises.empty?` with `false` or changing the return value to `:new__mutant__` survives because no test creates a lesson with zero exercises where prerequisites are met.

**`intervals.size < exercises.size` branch (2 mutants):** Minor mutations to the comparison that survive because test data always has reviews for all exercises or none.

### CurriculumValidator (19 survived)

**`visit_state[id] == UNVISITED` guard in detect_cycles! (5 mutants):** Replacing the condition with `true`, `UNVISITED` (always truthy), `visit_state[nil]`, or removing the guard entirely all survive because the algorithm still produces correct results for the test's small DAGs (re-visiting already-done nodes does not cause false cycle detection).

**`visit_state[neighbor] == UNVISITED` guard in dfs_visit! (5 mutants):** Same pattern -- the guard is an optimization, not a correctness requirement for small graphs.

**Other DFS structural mutants (9):** Mutations to `visit_state[node] = DONE`, adjacency graph construction details, and `validate_prerequisite_ids!` iteration that survive because test DAGs are small enough that the mutations don't affect correctness.

## Analysis

All 7 services exceed the 80% kill rate threshold. The surviving mutants fall into predictable categories:

1. **Untested boundary values** (ScoreCalculator `<=30`, SessionTracker `>=850`/`>=900`/`>=1`): Tests use values well within ranges rather than exact boundaries.
2. **Untested output fields** (SM2Engine `next_review_date`): Tests assert interval/repetitions/ease_factor but not the derived date.
3. **Guards on paths not exercised** (QueueBuilder type guard, PrerequisiteChecker early return optimization): Defensive code that no test triggers.
4. **Algorithm optimizations equivalent for small inputs** (CurriculumValidator DFS visit guards): Mutations produce equivalent behavior on small test DAGs.
5. **Initial-value coincidences** (SessionTracker `streak_count + 1` vs `1` when starting from 0): Test starts from zero, so the mutation is undetectable.

No test improvements were required since all services exceed the 80% threshold.
