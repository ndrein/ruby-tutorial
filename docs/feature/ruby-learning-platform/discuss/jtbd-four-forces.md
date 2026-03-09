# JTBD Four Forces Analysis — Ruby Learning Platform

## Overview

The Four Forces of Progress framework (Moesta) explains when and why a user switches from their current approach to a new solution. For a switch to happen, Push + Pull must exceed Anxiety + Habit. This analysis covers the primary job and four key features.

```
        PROGRESS (switch happens)
             ^
Push of      |      Pull of
Current  ----+---- New Solution
Situation    |
             |
        NO PROGRESS (staying put)
             ^
Anxiety  ----+---- Habit of
of New        |    Present
Solution      |
```

---

## Analysis 1: Primary Job — Daily Ruby Fluency Practice

### Demand-Generating Forces

**Push: Frustration with current approach**
- Every tutorial, course, and documentation site assumes zero programming background
- Experienced developer wastes 70%+ of session time on concepts (variables, OOP, loops) already mastered in Python/Java
- Ad-hoc learning (docs on demand, Stack Overflow searches) produces no durable retention
- Writing Ruby code feels like "Python with Ruby syntax" — the idioms never become instinctive
- Embarrassing in code reviews when Ruby-specific patterns are not used

**Pull: Attractiveness of the new solution**
- Tool skips all known-knowledge concepts; content starts exactly where Python/Java expertise ends
- SM-2 scheduling eliminates the meta-cognitive work of "what should I study today?"
- 15-minute hard-capped sessions fit any schedule; daily consistency is achievable
- Progress reflects genuine retention, not artificial gamification
- Keyboard-native navigation matches professional developer workflow

### Demand-Reducing Forces

**Anxiety: Fears about the new approach**
- "What if the tool incorrectly judges what I already know and leaves gaps?"
- "Will SM-2 scheduling feel arbitrary — too much on some days, nothing on others?"
- "What if 15 minutes is not enough to make real progress?"
- "What if the lesson tree prerequisites feel like artificial gatekeeping rather than logical sequencing?"
- "Will I be able to find the topics I care about (e.g. Enumerable) without going through everything first?"

**Habit: Inertia of the current approach**
- Documentation on demand "works well enough" for immediate tasks even if retention is poor
- No existing daily learning habit to attach this to; building a new ritual is friction
- Current approach (search, read, apply) is familiar and requires no tool onboarding
- Developers are skeptical of "productivity tools" that add process overhead

### Assessment

| Force | Strength | Evidence |
|-------|----------|---------|
| Push | HIGH | Explicit pain: time waste on known content, poor retention, non-idiomatic output |
| Pull | HIGH | Clear solution-fit: SM-2 + expert calibration directly addresses the pain |
| Anxiety | MEDIUM | Real but addressable: good prerequisite design and onboarding resolves most fears |
| Habit | MEDIUM | Existing ad-hoc approach is weak (no retention); habit formation cost is manageable |

**Switch likelihood**: HIGH
**Key blocker**: Anxiety about gaps from skipping beginner content
**Key enabler**: Expert calibration that visibly skips known material (user sees this happening)
**Design implication**: Onboarding must explicitly signal "we are skipping what you already know." First session must feel calibrated to the user's level within the first 2 minutes.

---

## Analysis 2: SM-2 Automated Review Queue (OPP-2, Score 16)

### Demand-Generating Forces

**Push**
- Manual selection of what to review requires meta-cognitive effort that depletes willpower
- Humans chronically over-weight recent memories and under-review older material that is fading
- Without scheduled review, concepts learned in session decay within a week
- "Should I re-do lesson 3 or move forward?" is a real daily friction point

**Pull**
- Opening the app and having the queue ready is effortless — the decision is already made
- SM-2 is a proven algorithm; trust in the system replaces manual judgment
- Retention metrics become visible and accurate because the algorithm actually tracks recall

### Demand-Reducing Forces

**Anxiety**
- "What if I have 20 reviews due one day and none the next?"
- "What if a concept I want to skip keeps appearing in the queue?"

**Habit**
- Re-reading notes or lesson content is the current review habit; it feels productive even without retention evidence

### Assessment

**Switch likelihood**: HIGH (strongest opportunity score in discovery)
**Key blocker**: Unpredictable review volume
**Design implication**: Show review count at session start with time estimate. Cap daily review load or provide overflow handling.

---

## Analysis 3: Topic Selection / Lesson Tree (OPP-1, Score 15)

### Demand-Generating Forces

**Push**
- Linear forced progression through a 25-lesson curriculum is slow for someone who wants to reach Enumerable (Module 2) quickly
- Not knowing what is locked/unlocked creates frustration when trying to plan a learning path
- No visibility into prerequisite graph means attempting lessons without context

**Pull**
- Seeing the full curriculum tree and being able to select a target topic (even while gated) gives a sense of agency
- Prerequisite gates that explain WHY a lesson is locked feel educational rather than arbitrary
- Being able to jump to a specific topic when work demands it (e.g., "I need to understand blocks for this PR") is a high-value escape hatch

### Demand-Reducing Forces

**Anxiety**
- "What if I bypass prerequisites and get confused?"
- "Will the prerequisite logic be too conservative and gate things I already know?"

**Habit**
- Linear documentation reading is the current habit; a tree structure requires a different mental model

### Assessment

**Switch likelihood**: HIGH
**Key blocker**: Anxiety that prerequisite gates are too conservative
**Design implication**: Show the prerequisite graph explicitly. Explain WHAT is needed before what, not just THAT something is needed. Allow user to view locked lesson content in preview mode (read-only) so they can judge whether the gate is appropriate.

---

## Analysis 4: Session Length Discipline (OPP-3, Score 15)

### Demand-Generating Forces

**Push**
- Open-ended learning sessions are unpredictable; a 15-minute session can turn into 45 minutes
- Long sessions are unsustainable; they compete with work and life
- Inconsistent session lengths produce inconsistent learning; daily 15-minute sessions beat weekly 2-hour sessions

**Pull**
- Hard time cap makes the practice feel like a professional commitment (like a daily standup) rather than open-ended studying
- Knowing the session ends at a fixed time reduces procrastination around starting

### Demand-Reducing Forces

**Anxiety**
- "What if I am mid-exercise when 15 minutes is up? Will I lose progress?"
- "Will 30 seconds per review exercise be enough time?"

**Habit**
- Current ad-hoc learning has no time structure; imposing a cap requires behavior change

### Assessment

**Switch likelihood**: HIGH
**Key blocker**: Fear of losing mid-session progress
**Design implication**: Sessions always complete cleanly. Timer shows time remaining, not elapsed. If review queue overruns, defer excess reviews to next session (never truncate mid-exercise).

---

## Analysis 5: Keyboard-Native Navigation (OPP-4, Score 12)

### Demand-Generating Forces

**Push**
- Mouse-dependent learning tools break keyboard flow that developers maintain throughout the workday
- Context-switching to mouse for a learning tool creates micro-friction that accumulates into discouragement

**Pull**
- Keyboard-native tool matches the professional identity of a developer who uses vim/tmux/terminal
- Visible focus states and shortcut hints make the tool feel like a professional instrument

### Demand-Reducing Forces

**Anxiety**
- "Will I have to learn a new set of shortcuts just for this tool?"
- "What if I forget a keybinding mid-session?"

**Habit**
- Web applications typically require mouse; developers who use keyboard-heavy editors adapt to mouse for web apps

### Assessment

**Switch likelihood**: MEDIUM-HIGH
**Key blocker**: Discoverability of shortcuts
**Design implication**: Shortcuts should follow vim conventions where applicable (j/k navigation, Enter to select, Esc to back out). Display shortcut hints in the UI. Persistent shortcut reference accessible via `?` key.

---

## Cross-Force Summary

| Opportunity | Push | Pull | Anxiety | Habit | Net Score | Priority |
|-------------|------|------|---------|-------|-----------|---------|
| SM-2 review queue | HIGH | HIGH | LOW | MEDIUM | STRONG | Must Have |
| Expert calibration | HIGH | HIGH | MEDIUM | LOW | STRONG | Must Have |
| Session discipline | HIGH | HIGH | LOW | MEDIUM | STRONG | Must Have |
| Keyboard navigation | MEDIUM | HIGH | LOW | LOW | STRONG | Must Have |
| Progress visibility | MEDIUM | HIGH | LOW | LOW | STRONG | Must Have |
| Topic selection | MEDIUM | HIGH | MEDIUM | LOW | STRONG | Should Have |
| Rails extensibility | LOW | MEDIUM | LOW | LOW | WEAK | Won't Have (MVP) |
