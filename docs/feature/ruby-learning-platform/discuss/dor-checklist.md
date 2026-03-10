# Definition of Ready Checklist — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 3 (Final Gate)
**Date**: 2026-03-09
**Validator**: Luna (product-owner agent)
**Purpose**: Hard gate — all 8 DoR items must pass before handoff to DESIGN wave.

---

## DoR Item 1: Problem Statement Clear, Domain Language

**Status: PASS**

**Evidence**:

The problem statement is defined in customer domain language, sourced directly from the
DISCOVER wave interview log and validated in `problem-validation.md` (G1 PASS).

Customer words (verbatim from interview-log.md):
> "I know Python and Java well. I only need Ruby syntax — not variables, loops, or OOP
> explained from scratch. I want short, dense, high-signal lessons I can finish in under
> 5 minutes with 30-second review exercises. Total daily session under 15 minutes. I want
> spaced repetition driving what I review so I don't have to decide."

Every user story in `user-stories.md` contains a "Problem" section written in domain
language (e.g., "Marcus Chen visits the platform for the first time... If the first thing
he sees is beginner content, he will leave and not return."). No story uses implementation
language ("build a controller", "create a database table") in the problem section.

Requirements in `requirements.md` use domain terminology throughout:
- "expert-calibrated curriculum" (not "filtered content table")
- "spaced repetition" and "SM-2" (not "scheduling algorithm")
- "habit sustainability" (not "user retention rate")

---

## DoR Item 2: User/Persona with Specific Characteristics

**Status: PASS**

**Evidence**:

Primary persona **Marcus Chen** is defined in `jtbd-job-stories.md` with:
- Role: Senior software engineer, 8 years experience
- Background: Python + Java expert; joining a Ruby on Rails team
- Time constraint: 15 minutes pre-standup morning window
- Interface preference: vim/terminal native; mouse is a context switch
- Prior tool experience: executeprogram.com — found it too beginner-calibrated
- Values: information density; systematic skill building; precision

Marcus Chen appears in all three journey maps with specific context:
- Onboarding journey: first-time visitor, skeptical, 45 seconds from landing to Lesson 1
- Daily session journey: week 1 user, 6-day streak, 8:47 AM, 13 minutes before standup
- Topic selection journey: week 2 user, 14-day streak, exploring Module 2 progression

Marcus Chen is named and contextualized in all 20 user stories in `user-stories.md`.
Additional persona Ana Folau (US-001) provides the "beginner trying to use an expert tool"
edge case.

The persona is not generic ("experienced developer") — it is specific (Python/Java background,
named, time-constrained, preference-specific, with named prior tool experience).

---

## DoR Item 3: >= 3 Domain Examples with Real Data

**Status: PASS**

**Evidence**:

Every user story in `user-stories.md` contains exactly 3 domain examples with real
persona names and realistic data. No example uses "user123", "test@test.com", or
generic data.

Selected examples demonstrating real data:

**US-000 (Walking Skeleton)**:
- Example 1: "Marcus types 'select' into Exercise 1.1... SM-2 creates a review entry scheduled for today + 3 days"
- Example 2: "Marcus types 'filter' (Python habit) instead of 'select'... SM-2 schedules for today + 1 day"
- Example 3: "Marcus lets the timer expire... SM-2 records a score of 0"

**US-001 (Onboarding)**:
- Example 1: "Marcus types marcus@example.com... presses Enter... routes to Lesson 1: Ruby Blocks"
- Example 2: "Ana Folau selects 'No — I'm newer to programming'..." (different persona, edge case)
- Example 3: "Marcus types an email already registered... sees 'This email is already registered'"

**US-007 (SM-2 Algorithm)**:
- Example 1: "repetitions=0, EF=2.5... output: interval=6 days, EF=2.5" (specific SM-2 parameters)
- Example 2: "EF degrades from 2.5 → 2.14 → 1.86 → 1.64" (specific degradation sequence)
- Example 3: "EF has degraded to 1.32... New EF formula yields 1.11 — clamped to 1.3"

**US-013 (Retention Rate)**:
- Example 1: "Marcus has completed 43 SM-2 reviews in the past 14 days. 31 were correct. Rate = 72%"
- Example 2: "Only 5 reviews, all correct. Rate = 100%. Note: 'based on 5 reviews'"
- Example 3: "Marcus has not completed any sessions in 14 days. 'No reviews in past 14 days'"

All 20 stories follow this pattern. Lesson numbers, exercise types, keyboard shortcuts, and
timing values are specific and consistent with the DISCOVER artifacts.

---

## DoR Item 4: UAT in Given/When/Then (3-7 Scenarios)

**Status: PASS**

**Evidence**:

All 20 user stories contain UAT scenarios in Given/When/Then format. Scenario counts per story:

| Story | Scenario Count | Within Range |
|-------|---------------|-------------|
| US-000 | 3 | PASS |
| US-001 | 4 | PASS |
| US-002 | 4 | PASS |
| US-003 | 3 | PASS |
| US-004 | 3 | PASS |
| US-005 | 4 | PASS |
| US-006 | 3 | PASS |
| US-007 | 5 | PASS |
| US-008 | 3 | PASS |
| US-009 | 3 | PASS |
| US-010 | 3 | PASS |
| US-011 | 3 | PASS |
| US-012 | 3 | PASS |
| US-013 | 3 | PASS |
| US-014 | 4 | PASS |
| US-015 | 3 | PASS |
| US-016 | 3 | PASS |
| US-017 | 3 | PASS |
| US-018 | 3 | PASS |
| US-019 | 3 | PASS |
| US-020 | 3 | PASS |

All scenarios follow strict Given/When/Then format. All scenarios include concrete data
(exercise IDs, time values, streak counts, SM-2 parameters). No scenario uses abstract
data or "it should work" language.

Full BDD acceptance criteria in `acceptance-criteria.md` expands these into 50+ precise
AC-NNN-NN numbered criteria, all in Given/When/Then format.

The three journey Gherkin files add further end-to-end scenarios:
- `journey-onboarding.feature`: 14 scenarios
- `journey-daily-session.feature`: 13 scenarios
- `journey-topic-selection.feature`: 13 scenarios

---

## DoR Item 5: Acceptance Criteria Derived from UAT

**Status: PASS**

**Evidence**:

`acceptance-criteria.md` contains 50+ acceptance criteria organized by story (AC-000 through
AC-020) plus 5 cross-cutting criteria (XC-001 through XC-005).

Each AC entry:
1. References its parent story by number (e.g., "AC-007" derives from "US-007: SM-2 Algorithm Core")
2. Uses Given/When/Then format
3. Contains specific, observable, testable conditions (no vague language)
4. Is derived directly from the UAT scenarios in the corresponding user story

Traceability chain: DISCOVER interview → JTBD job story → journey artifact → user story
(problem + examples + UAT scenarios) → acceptance criteria (observable assertions).

Selected examples of derived AC:

**US-007 UAT Scenario**: "Third correct response uses EF multiplication"
→ **AC-007-03**: `Given repetitions=2, interval=6, EF=2.5 / When quality score 4 / Then interval = round(6 * 2.5) = 15 days`

**US-006 UAT Scenario**: "Streak does not double-increment on same-day second session"
→ **AC-006-03**: `Given Marcus has already completed one session today (streak=7) / When Marcus completes a second session / Then session summary shows "Streak: 7 days"`

No acceptance criterion was written that does not trace back to a UAT scenario in a user story.

---

## DoR Item 6: Right-Sized (1-3 Days, 3-7 Scenarios)

**Status: PASS**

**Evidence**:

All 20 stories have explicit effort estimates ranging from 1 to 2-3 days. Scenario
counts are 3-5 per story. No story exceeds 3 days or 5 scenarios (within the 3-7 cap).

Story sizing summary:

| Size Category | Stories |
|--------------|---------|
| 1 day | US-004, US-006, US-007, US-008, US-010, US-011, US-012, US-013, US-015, US-017, US-018, US-019, US-020 (13 stories) |
| 1-2 days | US-001, US-002, US-003, US-005, US-009, US-014 (6 stories) |
| 2-3 days | US-000 (walking skeleton), US-016 (content production) (2 stories) |

US-000 (Walking Skeleton) is 2-3 days because it establishes the full vertical technology
stack for a greenfield project. This is appropriate — it is Feature 0.

US-016 (Lesson Content) is 2-3 days due to content production (25 lessons × 30 min = ~12 hours).
This is content work, not engineering — it fits within a single sprint even at 3 days.

Stories US-013 and US-015 are candidates to merge with their companion stories (US-012
and US-014 respectively) if the implementation team prefers fewer, slightly larger stories.
Both are noted as combinable in their Technical Notes sections.

No story is a candidate for splitting — all have coherent single user outcomes.

---

## DoR Item 7: Technical Notes — Constraints and Dependencies

**Status: PASS**

**Evidence**:

All user stories contain a "Technical Notes" section documenting constraints and dependencies.

Key technical constraints documented:

**US-000 (Walking Skeleton)**:
- "No authentication — access is unprotected for the walking skeleton"
- "Seed data required: 1 lesson, 1 exercise"
- "SM-2 state table must exist before testable"
- "This is the 'tracer bullet' — establishes full technology stack"

**US-007 (SM-2 Algorithm)**:
- "Algorithm is a pure function with no side effects (fully unit-testable)"
- EF minimum 1.3, maximum 2.5 — SM-2 spec compliance

**US-009 (Daily Email)**:
- "Failed delivery retried once; failure logged; app remains functional"

**Requirements.md** documents all non-functional requirements including:
- NFR-1: Performance targets (2-second render, 500ms feedback, 100ms SM-2 calculation)
- NFR-2: Reliability (transactional SM-2 persistence, idempotent queue builder)
- NFR-5: SM-2 algorithm fidelity (published spec compliance, unit test coverage)
- NFR-7: Data constraints (interval >= 1, EF in [1.3, 2.5], session_duration <= 1800)

**Out-of-scope constraints** are explicitly documented in requirements.md (Rails track,
push notifications, adaptive difficulty, weekly email, multi-user — all post-MVP with rationale).

**Shared Artifacts Registry** (`shared-artifacts-registry.md`) documents all 24 shared
variables, their sources, consumers, and integration risk levels — providing the dependency
map for DESIGN wave planning.

---

## DoR Item 8: Dependencies Resolved or Tracked

**Status: PASS**

**Evidence**:

All dependencies are either resolved (static DISCOVER artifacts) or tracked with explicit
resolution paths.

**Resolved dependencies**:

| Dependency | Resolution |
|-----------|------------|
| Problem statement | G1 PASS in problem-validation.md |
| Opportunity scores | G2 PASS in opportunity-tree.md |
| Solution concept | G3 PASS in solution-testing.md |
| Go/No-Go decision | G4 PASS (GO) in lean-canvas.md |
| Curriculum content plan | 25 lessons defined in solution-testing.md (Module 1-5, titles all specified) |
| SM-2 algorithm specification | Published SuperMemo SM-2 spec; reference implementations exist in Ruby |
| Keyboard map specification | Fully specified in solution-testing.md + requirements.md FR-6.2 |
| Exercise types | 5 types defined and validated in solution-testing.md |

**Tracked dependencies (not blockers for DESIGN, but post-design)**:

| Dependency | Owner | Status |
|-----------|-------|--------|
| Email delivery service selection (SendGrid/Postmark) | solution-architect (DESIGN wave) | Technology choice — not a product requirement |
| Database schema design | solution-architect (DESIGN wave) | Out of scope for DISCUSS |
| Authentication mechanism (magic link vs. session) | solution-architect (DESIGN wave) | US-001 notes email-only for MVP |
| Hosting platform choice | solution-architect (DESIGN wave) | lean-canvas.md documents options ($5-20/month) |
| Lesson content writing | Marcus Chen (builder = user) | 25 lessons x 30 min = ~12 hours; tracked in US-016 |
| SM-2 implementation language/library | solution-architect | Pure function; any language; unit-testable |

**Integration checkpoints tracked**: `shared-artifacts-registry.md` documents 7 HIGH risk
integration points across the three journeys:
- `experience_level` persistence → curriculum filtering (IC-1, Onboarding)
- `review_queue` consistency: email = app (IC-1, Daily Session)
- `sm2_score` → `sm2_interval` calculation chain (IC-2, Daily Session)
- `lesson_status` derivation from SM-2 state (IC-1, Topic Selection)
- `prerequisite_ids` gate real-time checking (IC-2, Topic Selection)

All HIGH-risk integrations are documented with failure modes. These become design
constraints for the DESIGN wave solution architect.

**Post-launch validation dependencies** (logged from DISCOVER G3):
- H1 (habit sustainability): 2-week usage trial required post-launch
- H5 (SM-2 interval quality): 2-week trial required post-launch
Neither is a blocker for DESIGN wave — both are iteration-2 validation items.

---

## DoR Summary

| # | Item | Status | Evidence Location |
|---|------|--------|-------------------|
| 1 | Problem statement clear, domain language | PASS | user-stories.md (Problem sections); problem-validation.md |
| 2 | User/persona with specific characteristics | PASS | jtbd-job-stories.md (Marcus Chen profile); all journey maps |
| 3 | >= 3 domain examples with real data | PASS | user-stories.md (all 20 stories, 3 examples each) |
| 4 | UAT in Given/When/Then (3-7 scenarios) | PASS | user-stories.md (3-5 per story); journey .feature files |
| 5 | AC derived from UAT | PASS | acceptance-criteria.md (50+ criteria, all traced to UAT) |
| 6 | Right-sized (1-3 days, 3-7 scenarios) | PASS | user-stories.md (effort estimates: 1-3 days; 3-5 scenarios each) |
| 7 | Technical notes: constraints/dependencies | PASS | user-stories.md (Technical Notes sections); requirements.md NFR section |
| 8 | Dependencies resolved or tracked | PASS | This checklist, items table above; shared-artifacts-registry.md |

**All 8 DoR items: PASS**

---

## Handoff Decision

**Decision: APPROVED FOR DESIGN WAVE HANDOFF**

All Definition of Ready criteria have been met with documentary evidence. The DISCUSS
wave is complete and the following artifacts are ready for handoff to the solution-architect
(DESIGN wave):

### Handoff Package

**JTBD Artifacts**:
- `docs/feature/ruby-learning-platform/discuss/jtbd-job-stories.md`
- `docs/feature/ruby-learning-platform/discuss/jtbd-four-forces.md`
- `docs/feature/ruby-learning-platform/discuss/jtbd-opportunity-scores.md`

**Journey Artifacts**:
- `docs/feature/ruby-learning-platform/discuss/journey-onboarding-visual.md`
- `docs/feature/ruby-learning-platform/discuss/journey-onboarding.yaml`
- `docs/feature/ruby-learning-platform/discuss/journey-onboarding.feature`
- `docs/feature/ruby-learning-platform/discuss/journey-daily-session-visual.md`
- `docs/feature/ruby-learning-platform/discuss/journey-daily-session.yaml`
- `docs/feature/ruby-learning-platform/discuss/journey-daily-session.feature`
- `docs/feature/ruby-learning-platform/discuss/journey-topic-selection-visual.md`
- `docs/feature/ruby-learning-platform/discuss/journey-topic-selection.yaml`
- `docs/feature/ruby-learning-platform/discuss/journey-topic-selection.feature`
- `docs/feature/ruby-learning-platform/discuss/shared-artifacts-registry.md`

**Requirements and Stories**:
- `docs/feature/ruby-learning-platform/discuss/requirements.md`
- `docs/feature/ruby-learning-platform/discuss/user-stories.md`
- `docs/feature/ruby-learning-platform/discuss/acceptance-criteria.md`
- `docs/feature/ruby-learning-platform/discuss/dor-checklist.md`

### Key Design Constraints for DESIGN Wave

1. **SM-2 algorithm** must be implemented as a pure function conforming to published SM-2 spec (FR-2.1-2.9, NFR-5)
2. **Session hard cap** must be structural — enforced by the platform, not user willpower (FR-9, US-020)
3. **Keyboard navigation** must cover the full keyboard map (FR-6.2) with focus states meeting 3:1 contrast (FR-6.3, NFR-4.1)
4. **Review queue** must be built by a single source (daily queue builder) used by both email and app (shared-artifacts-registry.md: `${review_queue}`)
5. **Lesson status** must derive from SM-2 interval state, not an independent status field (shared-artifacts-registry.md: `${lesson_status}`)
6. **Daily email** must not contain promotional content (FR-4.7)
7. **Walking Skeleton (US-000)** must be the first story implemented — no other story can begin until the full vertical stack is proven working
8. **25 lessons** are fixed in scope for MVP; Rails extension is post-MVP (explicitly out of scope)
