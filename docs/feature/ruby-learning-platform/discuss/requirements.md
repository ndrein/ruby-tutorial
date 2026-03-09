# Requirements — Ruby Learning Platform

## Product Context

A single-user web application for experienced developers (Python/Java background) learning Ruby syntax and idioms. Not a beginner tool. Daily 15-minute sessions. SM-2 spaced repetition drives review scheduling. Keyboard-native UI.

## Persona

**Ana Folau** — senior Python/Java developer, joining a Ruby team. Values efficiency, precision, and being treated as an expert. Practices daily, 15 minutes, before standup.

## Design Principles (Non-Negotiable)

1. **No beginner scaffolding** — assume OOP, variables, loops are known
2. **SM-2 automation first** — user never manually selects what to review
3. **Daily session = review queue + 1 new lesson** — fixed structure
4. **30-second hard cap per exercise** — no exceptions
5. **Keyboard-first navigation** — no action requires a mouse
6. **Progress visible but not gamified** — no XP, badges, streaks shown prominently

---

## Epics

### Epic 1: Curriculum (Lesson Tree + Prerequisites)

Manage the 25-lesson curriculum as a directed acyclic graph. Lessons are nodes; prerequisites are directed edges. User cannot access a lesson until all its prerequisites are complete.

**Business rules:**
- Module 1 (L1-L5) has no module-level prerequisite; L1 is unlocked at first launch
- Each lesson within a module has per-lesson prerequisites (see curriculum schema)
- Completing a lesson triggers prerequisite_resolver to unlock newly available lessons
- Unlock is atomic with lesson completion (no partial states)
- A user can VIEW locked lesson topics but cannot DO exercises until unlocked

### Epic 2: SM-2 Spaced Repetition Engine

Implement the SM-2 algorithm to schedule exercise reviews. SM-2 is the primary driver of daily sessions; manual review selection is not exposed.

**Business rules:**
- Each exercise has: ease_factor (start 2.5), interval (start 1 day), next_review_date
- After correct answer: new_interval = max(1, prev_interval * ease_factor)
- After incorrect answer: new_interval = 1 day; ease_factor decreases by 0.2 (min 1.3)
- Partial/skipped: ease_factor unchanged; interval remains or resets to 1 day
- Daily review queue = exercises where next_review_date <= today
- Daily cap: max 12 exercises or 6 minutes of review, whichever comes first
- Deferred exercises carry to next session as high-priority (appear first)

### Epic 3: Daily Session Flow

Structure each session as: (1) SM-2 review queue, (2) one new lesson. Session must complete within 15 minutes. System plans session; user executes.

**Business rules:**
- Session starts with pre-computed plan; no decisions required from user
- Review queue runs before new lesson (always)
- New lesson = next available lesson per prerequisite graph
- Session time cap: 15 minutes total
- If time cap reached mid-exercise: complete current exercise, defer rest
- Session persists to storage atomically when complete

### Epic 4: Onboarding

First-time user experience that immediately signals expert calibration and gets Ana to her first exercise within 5 minutes.

**Business rules:**
- No account creation or login (single-user tool)
- Welcome screen must show assumed-knowledge list before showing curriculum
- Lesson 1 must be the first and only available lesson at launch
- SM-2 initializes on completion of first exercise

### Epic 5: Topic Selection / Lesson Tree Navigation

User-facing curriculum tree with visual lock/unlock states and an explicit lock screen that explains prerequisites educationally.

**Business rules:**
- Curriculum tree shows all 25 lessons with status icons ([x] complete, [ ] available, [~] locked)
- Locked lesson lock screen shows: why locked, target lesson topics, prerequisite lesson topics
- Lock screen always has a path forward ([Enter] = go to prerequisite)
- No force-skip mechanism — prerequisite gates are absolute
- Keyword search filters the tree inline
- [t] shortcut from session dashboard opens topic selection

### Epic 6: Progress Dashboard

Non-gamified progress view showing real retention data from SM-2.

**Business rules:**
- No XP, badges, levels, or achievement notifications
- Show: lessons complete / total, SM-2 retention score per completed lesson, streak (days with completed session), next review forecast
- Retention score = % of last 10 SM-2 answers that were correct for that lesson's exercises
- Dashboard accessible from any screen via [p] shortcut

### Epic 7: Keyboard Navigation

Every interactive element in the application is reachable and operable without a mouse.

**Business rules:**
- j/k for up/down navigation within lists
- J/K (shift) for jumping between sections/modules
- Enter to select/submit/advance
- Esc to go back / cancel
- / to open search
- ? to show keyboard shortcut reference
- p to open progress dashboard from any screen
- t to open topic selection from session dashboard
- n to start next lesson from session complete screen
- Tab to show hint in exercise view
- All focus states visible (not just browser default)

---

## Non-Functional Requirements

### Performance
- Session dashboard must render within 500ms of opening
- SM-2 queue computation must complete within 200ms
- Exercise feedback must render within 100ms of submission
- Curriculum tree with 25 lessons must render within 300ms

### Reliability
- SM-2 state must survive browser refresh / tab close mid-session
- Lesson completion is atomic: either all exercises commit or none do
- No data loss on navigation (pressing Esc mid-lesson saves position)

### Usability
- All keyboard shortcuts discoverable via [?] overlay
- Focus indicators visible on all interactive elements (WCAG 2.2 AA)
- No action requires more than 3 keypresses from any screen

### Constraints
- Single-user: no authentication, no multi-user state
- No gamification elements (no XP, badges, leaderboards, streaks as primary metric)
- No beginner content (exercises must reference Python/Java equivalents)
- Rails extensibility deferred to post-MVP (OPP-6, score 7)

---

## Business Rules Glossary

| Rule | Definition |
|------|-----------|
| BR-01 | Lesson 1 is always available at first launch |
| BR-02 | A lesson is available iff all its prerequisite lessons are complete |
| BR-03 | SM-2 review queue = exercises with next_review_date <= today |
| BR-04 | Daily review cap = min(12 exercises, 6 minutes) |
| BR-05 | Exercise time cap = 30 seconds (timer auto-reveals answer at expiry) |
| BR-06 | Session time cap = 15 minutes (current exercise completes; rest deferred) |
| BR-07 | SM-2 correct: new_interval = max(1, prev_interval * ease_factor) |
| BR-08 | SM-2 incorrect: new_interval = 1, ease_factor -= 0.2 (min 1.3) |
| BR-09 | SM-2 skipped: re-queue for next session, ease_factor unchanged |
| BR-10 | Unlock is atomic with lesson completion (no partial unlock states) |
| BR-11 | Progress metrics derive from SM-2 data, not manual input |
| BR-12 | Session plan (review count + next lesson) computed on session open, cached for session |

---

## Dependency Map

| Story | Depends On |
|-------|-----------|
| US-02 Daily Session | US-05 SM-2 Engine, US-08 Lesson Tree |
| US-03 Topic Selection | US-08 Lesson Tree |
| US-04 Exercise Timer | (standalone) |
| US-05 SM-2 Engine | US-04 Exercise Timer |
| US-06 Lesson Content | US-08 Lesson Tree |
| US-07 Keyboard Navigation | All UI stories |
| US-08 Lesson Tree | US-06 Lesson Content |
| US-09 Progress Dashboard | US-05 SM-2 Engine, US-08 Lesson Tree |
| US-01 Onboarding | US-08 Lesson Tree, US-04 Exercise Timer, US-05 SM-2 Engine |
| US-10 Email/Notification | US-05 SM-2 Engine (post-MVP) |
