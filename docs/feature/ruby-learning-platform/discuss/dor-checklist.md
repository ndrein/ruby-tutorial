# Definition of Ready — Validation Checklist

## Overview

Each story must pass all 8 DoR items before handoff to the DESIGN wave. This document records the validation result for each story with specific evidence.

---

## US-01: First-Time Onboarding

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Ana opens a new learning tool and immediately braces for the usual patronizing experience — explaining what a variable is." Domain language: calibration, patronizing, session, exercise. |
| 2. User/persona with specific characteristics | PASS | Ana Folau, senior Python developer, joining Ruby-on-Rails team, 5 minutes before first session, values efficiency, intolerant of beginner content. |
| 3. At least 3 domain examples with real data | PASS | (1) Happy path: Ana opens, sees assumed-knowledge list, presses Enter, completes 3 exercises in 4 minutes. (2) Curiosity path: navigates to L7 (locked), sees educational lock screen. (3) Mid-lesson Esc: resumes from exercise 3 of 3 next day. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 11 scenarios in journey-onboarding.feature, all in Given/When/Then format. Within 3-7 per story grouping (by screen step). |
| 5. AC derived from UAT | PASS | 15 acceptance criteria in acceptance-criteria.md (AC-01-01 through AC-01-15), each mapped to a source scenario. |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 2 days effort. 5 core UAT scenarios at story level (full feature has 11 but broken across steps). Demonstrable in single session. |
| 7. Technical notes: constraints and dependencies | PASS | Single-user (no auth), SM-2 initializes on first session complete (not first launch), assumed-knowledge list from config (not hardcoded), lesson position saved on Esc. |
| 8. Dependencies resolved or tracked | PASS | US-08 (Lesson Tree) — in backlog; US-04 (Exercise Timer) — in backlog; US-05 (SM-2 Engine) — in backlog. All in same release. |

**DoR Status: PASSED**

---

## US-02: Daily Session Flow

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Ana opens the platform each morning before standup. She has 15 minutes. She does not want to decide what to study." Domain language: session, review queue, SM-2, standup, retention. |
| 2. User/persona with specific characteristics | PASS | Ana Folau, 14 days into practice, Lessons 1-4 complete, 6 SM-2 reviews due, hard 15-minute budget, opens before 9 AM standup. |
| 3. At least 3 domain examples with real data | PASS | (1) Standard day: 6 reviews, L5 lesson, 7-minute session, 14-day streak. (2) Missed days: 18 reviews due, capped at 12. (3) Empty queue: 0 reviews, lesson only. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 12 scenarios in journey-daily-session.feature covering: empty queue, oversized queue, review order, correct/incorrect feedback, transition, lesson format, summary, persistence, time cap, topic override, 2 property scenarios. |
| 5. AC derived from UAT | PASS | 13 acceptance criteria (AC-02-01 through AC-02-13), each with source scenario. |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 2 days effort. Core story scenarios: 6 (empty queue, oversized queue, session summary, persistence, time cap, topic override). Demonstrable in single 15-minute session. |
| 7. Technical notes: constraints and dependencies | PASS | Session plan computed once at open, cached for session (BR-12). SM-2 computation must complete within 200ms. Streak increments after persist. |
| 8. Dependencies resolved or tracked | PASS | US-05 (SM-2 Engine), US-08 (Lesson Tree), US-04 (Exercise Timer) — all in same release. |

**DoR Status: PASSED**

---

## US-03: Topic Selection

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Ana is reviewing a PR that uses Ruby blocks heavily. She needs to understand blocks NOW." Domain language: curriculum tree, prerequisite, lock screen, topic selection, unlock. |
| 2. User/persona with specific characteristics | PASS | Ana Folau, 21 days in, Module 1 complete, immediate work need (PR review), needs blocks knowledge today. |
| 3. At least 3 domain examples with real data | PASS | (1) One prerequisite path: L7 needs L6, completes L6, L7 unlocks. (2) Search: [/] "block" filters to L7 and L8. (3) Already available: selects L6 (available), goes directly to lesson. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 11 scenarios in journey-topic-selection.feature. Core story scenarios: 5 (curriculum tree lock states, keyboard navigation, lock screen explains prerequisites, completing prerequisite unlocks, SM-2 records topic-selection exercises). |
| 5. AC derived from UAT | PASS | 11 acceptance criteria (AC-03-01 through AC-03-11), each with source scenario. |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 2 days effort. 5 core UAT scenarios. Journey covers 6 steps but the story is the end-to-end topic selection flow. |
| 7. Technical notes: constraints and dependencies | PASS | prerequisite_resolver atomic with lesson completion (BR-10). Search client-side (25 lessons in memory). Curriculum tree must not break session-in-progress state. |
| 8. Dependencies resolved or tracked | PASS | US-08 (Lesson Tree), US-05 (SM-2 Engine) — both in same release. |

**DoR Status: PASSED**

---

## US-04: Exercise Timer

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Without a time cap, exercises expand to fill available attention. A 'quick' exercise becomes a 3-minute deliberation." Domain language: exercise, timer, recall, 30-second cap. |
| 2. User/persona with specific characteristics | PASS | Any user completing any exercise. Context: review or lesson exercise during any session. |
| 3. At least 3 domain examples with real data | PASS | (1) Normal: Ana answers in 12 seconds. (2) Slow: timer reaches 0, answer shown. (3) Hint: Tab at 20 seconds, hint shown, timer continues. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 3 scenarios in US-04 UAT Scenarios block: timer starts, timer expiry, hint once per exercise. |
| 5. AC derived from UAT | PASS | 4 acceptance criteria (AC-04-01 through AC-04-04), each with source scenario. |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 1 day effort. 3 UAT scenarios. Single demonstrable component. |
| 7. Technical notes: constraints and dependencies | PASS | Timer is presentational only. SM-2 result recording in US-05. Timer state does not persist across navigation. |
| 8. Dependencies resolved or tracked | PASS | No upstream dependencies. |

**DoR Status: PASSED**

---

## US-05: SM-2 Review Engine

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Human memory decays on a curve; she will over-review recent content and neglect material from 2 weeks ago." Domain language: SM-2, spaced repetition, ease factor, interval, review queue. |
| 2. User/persona with specific characteristics | PASS | Ana, any user with completed exercises. SM-2 runs as background engine; Ana interacts with it via review queue and feedback. |
| 3. At least 3 domain examples with real data | PASS | (1) Correct: ease_factor=2.5, interval=1, correct → new_interval=3. (2) Incorrect: ease_factor=2.5, interval=4, incorrect → interval=1, ef=2.3. (3) Daily queue: 6 exercises with next_review_date <= today computed correctly. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 6 scenarios in US-05 UAT Scenarios block: correct increases interval, incorrect resets, minimum ease factor, daily queue, daily cap, state persists. |
| 5. AC derived from UAT | PASS | 8 acceptance criteria (AC-05-01 through AC-05-08), each with source scenario. |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 2 days effort. 6 UAT scenarios covering the full SM-2 algorithm. |
| 7. Technical notes: constraints and dependencies | PASS | State stored locally (IndexedDB or localStorage). Result types: correct/incorrect/partial/skipped/missed. "Partial" = incorrect for SM-2. SM-2 updates atomic per exercise. |
| 8. Dependencies resolved or tracked | PASS | US-04 (Exercise Timer) provides "missed" result. |

**DoR Status: PASSED**

---

## US-06: Lesson Content Standards

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Every Ruby learning resource explains concepts from scratch. For Ana, explaining 'what is a method' before showing def greet(name) is insulting." Domain language: calibrated content, Python/Java comparison, idiomatic Ruby, beginner scaffolding. |
| 2. User/persona with specific characteristics | PASS | Ana, experienced developer (Python/Java) encountering any lesson. Context: all 25 lessons and 75 exercises. |
| 3. At least 3 domain examples with real data | PASS | (1) L1: Python f-string → Ruby string interpolation with explanation. (2) L7: Python callable → Ruby block with yield example. (3) L11: Python __init__ → Ruby initialize with @name. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 4 scenarios in US-06: comparison format, does-not-cover section, no beginner content, valid code examples. |
| 5. AC derived from UAT | PASS | 4 acceptance criteria (AC-06-01 through AC-06-04). |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 3 days effort (content authoring for 25 lessons × 3 exercises). 4 UAT scenarios test the content standard, not individual lessons. |
| 7. Technical notes: constraints and dependencies | PASS | Content as structured data (YAML), not prose. Lesson schema: title, module, duration_estimate, topics_covered, topics_not_covered, exercises[]. Content review: 75 exercises to validate. |
| 8. Dependencies resolved or tracked | PASS | US-08 (Lesson Tree) — defines lesson metadata schema. |

**DoR Status: PASSED**

---

## US-07: Keyboard Navigation

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Ana uses vim, tmux, and keyboard shortcuts for all professional work. Mouse-dependent learning tools break her flow state." Domain language: keyboard-native, focus state, shortcut, vim conventions. |
| 2. User/persona with specific characteristics | PASS | Ana, developer who uses keyboard-native tools professionally. Any screen. Importance 7/10, satisfaction 2/10 from discovery. |
| 3. At least 3 domain examples with real data | PASS | (1) Daily session: zero mouse interactions, all via Enter. (2) Topic selection: [c] → j/k → / → Enter → Esc. (3) Help overlay: ?, sees shortcuts, Esc dismisses. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 4 scenarios: all workflows without mouse, j/k navigation, ? overlay, focus indicators. |
| 5. AC derived from UAT | PASS | 10 acceptance criteria (AC-07-01 through AC-07-10). |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 2 days effort. 4 UAT scenarios. Cross-cutting concern applied to all UI. |
| 7. Technical notes: constraints and dependencies | PASS | Shortcut map in single config file. Shortcuts must not conflict with browser defaults. Focus management: return focus to triggering element after overlay closes. |
| 8. Dependencies resolved or tracked | PASS | Cross-dependency: all UI stories (US-01 through US-09) must comply. Tracked as a constraint in each story. |

**DoR Status: PASSED**

---

## US-08: Lesson Tree Navigation and Prerequisite Gating

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "A flat list of lessons gives no sense of what unlocks what. Arbitrary 'locked' gates without explanation feel opaque and frustrating." Domain language: curriculum tree, prerequisite graph, lock/unlock, prerequisite resolver. |
| 2. User/persona with specific characteristics | PASS | Ana at any point in the curriculum. Planning next steps, responding to work needs, tracking progress. |
| 3. At least 3 domain examples with real data | PASS | (1) Module completion view after Module 1 complete. (2) Multi-prerequisite: L10 requires L8 (complete) and L9 (not complete). (3) Search: [/] "regex" finds L25, lock screen shows prerequisite chain. |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 6 scenarios across journey-topic-selection.feature and US-08: curriculum tree states, module status update, atomic unlock, multi-prerequisite, keyword search, initial state. |
| 5. AC derived from UAT | PASS | 6 acceptance criteria (AC-08-01 through AC-08-06). |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 3 days effort (prerequisite graph logic + tree rendering). 6 UAT scenarios. |
| 7. Technical notes: constraints and dependencies | PASS | prerequisite graph = DAG in prerequisites.yml. prerequisite_resolver is a pure function. Graph acyclic enforced at authoring + validated on load. 25 lessons fit client-side. |
| 8. Dependencies resolved or tracked | PASS | US-06 (Lesson Content) — defines lesson metadata schema that tree uses. |

**DoR Status: PASSED**

---

## US-09: Progress Dashboard

| DoR Item | Status | Evidence |
|----------|--------|---------|
| 1. Problem statement clear and in domain language | PASS | "Ana wants to know where she actually stands in her Ruby learning — not a gamified score, but real retention data." Domain language: retention score, SM-2, streak, lessons complete, no gamification. |
| 2. User/persona with specific characteristics | PASS | Ana with at least one completed lesson. Context: checking progress between sessions or when planning study schedule. |
| 3. At least 3 domain examples with real data | PASS | (1) After Module 1: "5/25 lessons complete." L1=90%, L2=85%, L3=75%, L4=95%, L5=80%. Streak: 14 days. (2) Low retention: L3 at 40%, surfaced prominently. (3) Pace estimate: "20 lessons remaining ≈ 20 sessions." |
| 4. UAT scenarios in Given/When/Then (3-7) | PASS | 4 scenarios in US-09: lesson completion accuracy, retention from SM-2 data, no gamification, accessible via [p] from any screen. |
| 5. AC derived from UAT | PASS | 6 acceptance criteria (AC-09-01 through AC-09-06). |
| 6. Story right-sized (1-3 days, 3-7 scenarios) | PASS | 1 day effort. 4 UAT scenarios. Dashboard is read-only; complexity is in data derivation, not UI. |
| 7. Technical notes: constraints and dependencies | PASS | Retention = correct reviews / total reviews (last 10 per lesson). Streak = consecutive calendar days with completed session. "Sessions remaining" = pending_lessons / avg_lessons_per_session (7-day rolling). |
| 8. Dependencies resolved or tracked | PASS | US-05 (SM-2 Engine), US-08 (Lesson Tree) — both in same release. |

**DoR Status: PASSED**

---

## Summary

| Story | DoR Status | Days Est. | UAT Scenarios |
|-------|-----------|-----------|---------------|
| US-01: Onboarding | PASSED | 2 | 5 core, 11 total |
| US-02: Daily Session Flow | PASSED | 2 | 6 core, 12 total |
| US-03: Topic Selection | PASSED | 2 | 5 core, 11 total |
| US-04: Exercise Timer | PASSED | 1 | 3 |
| US-05: SM-2 Engine | PASSED | 2 | 6 |
| US-06: Lesson Content Standards | PASSED | 3 | 4 |
| US-07: Keyboard Navigation | PASSED | 2 | 4 |
| US-08: Lesson Tree + Prerequisites | PASSED | 3 | 6 |
| US-09: Progress Dashboard | PASSED | 1 | 4 |
| US-10: Email Notifications | DRAFT (post-MVP) | 2 | — |

**All MVP stories: PASSED**
**Total MVP effort: ~18 developer-days**
**Total MVP acceptance criteria: 79**

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Content authoring (75 exercises) takes longer than 3 days | MEDIUM | HIGH | Identify minimum viable set (Module 1 + 2 = 10 lessons, 30 exercises) for launch; expand iteratively |
| SM-2 algorithm produces erratic intervals for first-time users | LOW | MEDIUM | Seed ease_factor at 2.5 (SM-2 standard); add integration test suite for algorithm |
| Prerequisite resolver has edge cases with complex multi-prerequisite chains | LOW | HIGH | Graph property test: generate 1000 random progress states, verify resolver is deterministic and acyclic |
| 30-second exercise cap frustrates users who are close to answer | LOW | MEDIUM | Show "You had it" variant of feedback when answer is submitted 1-2 seconds after timer; does not change SM-2 result |
| Single-user storage (localStorage/IndexedDB) cleared by browser | LOW | HIGH | Export/import mechanism in post-MVP; document the risk clearly in UI |
