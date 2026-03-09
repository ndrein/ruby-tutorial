# JTBD Job Stories — Ruby Learning Platform

## Overview

This document expands the validated jobs-to-be-done discovered in the DISCOVER wave into full job story format. Each job story captures situation, motivation, expected outcome, and all three job dimensions (functional, emotional, social).

---

## Primary Job Story

### JS-01: Daily Syntax Fluency Practice

**When** I sit down for my morning development routine and want to move closer to Ruby fluency as an experienced developer already proficient in Python and Java,
**I want to** complete a short, precisely-calibrated daily practice session that tests exactly the Ruby concepts I am ready to absorb next,
**so I can** internalize idiomatic Ruby syntax to the point where I write it without stopping to check documentation.

#### Functional Job
Progress through Ruby-specific syntax and idioms at the pace an experienced developer deserves — fast through the familiar, deep on the genuinely new.

#### Emotional Job
Feel competent and efficient, not talked down to. The tool should treat me as an expert learning a new dialect, not a beginner learning programming.

#### Social Job
Be seen by colleagues as someone who writes idiomatic Ruby rather than "Python with Ruby syntax." Demonstrate Ruby literacy in code reviews.

#### Forces Analysis
- **Push**: Existing learning resources (documentation, tutorials, online courses) are calibrated for beginners; wading through variables, OOP basics, and loop syntax wastes 70%+ of session time on concepts already mastered.
- **Pull**: A tool that skips all known concepts and surfaces only the Ruby-specific differences would compress weeks of study into daily 15-minute focused practice.
- **Anxiety**: Will the tool correctly identify what I already know? Will it skip too much and leave gaps? Will SM-2 scheduling feel arbitrary rather than intelligent?
- **Habit**: Currently using ad-hoc approaches — reading Ruby docs on demand, skimming Rubyist blogs, searching Stack Overflow during coding — which works but does not build durable retention.

---

## Supporting Job Stories

### JS-02: Transfer Syntax Knowledge from Python/Java to Ruby

**When** I encounter a Ruby idiom that looks unfamiliar but probably maps to something I already know from Python or Java,
**I want to** quickly understand the Ruby-specific way of doing something I already understand conceptually,
**so I can** translate my existing programming mental model into Ruby without having to re-learn the underlying concept from scratch.

#### Functional Job
Map known programming concepts to their Ruby equivalents — not learn programming, but learn Ruby's dialect.

#### Emotional Job
Feel recognized as an expert. The tool should acknowledge what I already know and only ask me to stretch into genuinely new territory.

#### Social Job
Reduce the embarrassment of writing non-idiomatic Ruby ("Java in Ruby") in a team context where idiomatic code is valued.

#### Forces Analysis
- **Push**: Beginner tutorials explain "what is a loop" before showing Ruby's `each`. For an experienced developer this is patronizing and wastes time.
- **Pull**: Content structured as "you know X in Python, here is the Ruby equivalent" makes learning feel like translation not education.
- **Anxiety**: What if I miss something foundational by skipping "beginner" content? Am I building on a shaky foundation?
- **Habit**: Default to Python patterns when writing Ruby; relies on documentation rather than internalizing Ruby idioms.

---

### JS-03: Automated Daily Review Queue

**When** I open my learning tool at the start of a session and want to decide what to practice,
**I want to** have the system calculate and present today's review queue automatically based on my past performance and spacing intervals,
**so I can** eliminate the cognitive overhead of deciding what to study and trust that spaced repetition is handling retention optimization for me.

#### Functional Job
SM-2 algorithm schedules reviews automatically; user never manually selects what to revisit.

#### Emotional Job
Feel trust in the system. Every session should start with the quiet confidence that "the tool knows what I need today."

#### Social Job
Not directly social — but consistent retention means fewer embarrassing moments of forgetting concepts in pairing sessions.

#### Forces Analysis
- **Push**: Manual review selection requires meta-cognitive effort ("what did I struggle with last week?") and is chronically wrong — humans overweight recent memories and neglect older, fading ones.
- **Pull**: Algorithmic review scheduling removes a decision entirely; opening the app means the work is already organized.
- **Anxiety**: Will the algorithm feel intrusive? Will it schedule too many reviews on some days and none on others?
- **Habit**: Currently either re-reads everything (inefficient) or skips reviews entirely (no retention).

---

### JS-04: Session Length Discipline

**When** I have 15 minutes before standups or during a lunch break and want to fit in a practice session,
**I want to** complete a full, meaningful learning session within a hard 15-minute time budget,
**so I can** practice consistently every day without it competing with work commitments.

#### Functional Job
Session completes within 15 minutes: review queue (30 seconds per exercise) plus one new lesson (maximum 5 minutes).

#### Emotional Job
Feel that the time investment is respected. No session should run over; no exercise should drag past its natural limit.

#### Social Job
Being able to say "I practice Ruby every day for 15 minutes" is a credible habit; "I spend hours on it when I find time" is not.

#### Forces Analysis
- **Push**: Open-ended learning sessions balloon; starting a lesson and getting absorbed for 45 minutes creates guilt and schedule disruption.
- **Pull**: Hard time caps turn practice into a reliable daily ritual that fits real developer schedules.
- **Anxiety**: Will 15 minutes be enough? What if I am mid-lesson when the timer ends?
- **Habit**: Either over-invests when motivated (unsustainable) or skips entirely when busy (no consistency).

---

### JS-05: Keyboard-Native Navigation

**When** I am using my learning tool and want to move between exercises, submit answers, navigate the lesson tree, and manage my session,
**I want to** do everything without leaving the keyboard,
**so I can** stay in the focused, flow-state mode that keyboard-native developers rely on for all tool interactions.

#### Functional Job
Every interactive element reachable and operable via keyboard; no mouse required for any primary workflow.

#### Emotional Job
Feel at home in the tool. A developer who uses vim, tmux, and keyboard shortcuts everywhere should never feel the tool is fighting them.

#### Social Job
The tool should match the professional identity of a developer who takes their craft seriously.

#### Forces Analysis
- **Push**: Mouse-dependent learning tools break the keyboard-flow that developers maintain during work; context-switching to mouse creates friction that discourages daily use.
- **Pull**: A keyboard-native tool feels like a professional instrument, not a toy.
- **Anxiety**: Will all shortcuts be discoverable? What if I forget the keybinding?
- **Habit**: Every other professional tool (editor, terminal, git) is keyboard-native; this should be too.

---

### JS-06: Progress Visibility Without Gamification

**When** I want to understand how my Ruby learning is progressing,
**I want to** see a clear, honest view of completed lessons, SM-2 retention health, and what remains in the curriculum,
**so I can** calibrate my expectations about when I will have solid Ruby fluency and decide whether to adjust my daily practice commitment.

#### Functional Job
Dashboard showing completed/locked/available lessons, SM-2 retention scores per concept, and a total progress metric.

#### Emotional Job
Feel informed and in control. Progress should feel real (based on retention data) not inflated (artificial streaks, badges, points).

#### Social Job
Being able to say "I am 60% through the curriculum with 85% retention on completed lessons" is a meaningful signal to oneself and others.

#### Forces Analysis
- **Push**: Gamified systems (streaks, XP, badges) feel manipulative and hollow to professional developers; they obscure actual learning progress.
- **Pull**: Honest metrics based on SM-2 data reflect real retention, not engagement metrics.
- **Anxiety**: What if honest metrics show slow progress? Will that be discouraging?
- **Habit**: Developers are accustomed to metrics that reflect real system state (test coverage, build status); the same standard applies to learning tools.

---

## JTBD-to-Story Bridge

| Job Story | Primary User Stories |
|-----------|---------------------|
| JS-01: Daily Syntax Fluency Practice | US-01 (Onboarding), US-02 (Daily Session Flow), US-05 (SM-2 Review Engine) |
| JS-02: Transfer Syntax Knowledge | US-06 (Lesson Content Standards), US-08 (Lesson Tree Navigation) |
| JS-03: Automated Daily Review Queue | US-05 (SM-2 Review Engine), US-02 (Daily Session Flow) |
| JS-04: Session Length Discipline | US-02 (Daily Session Flow), US-04 (Exercise Timer) |
| JS-05: Keyboard-Native Navigation | US-07 (Keyboard Navigation), US-03 (Topic Selection) |
| JS-06: Progress Visibility | US-09 (Progress Dashboard), US-08 (Lesson Tree Navigation) |

---

## Domain Language Glossary

| Term | Definition |
|------|-----------|
| **Session** | A single daily practice event: review queue + one new lesson, completing within 15 minutes |
| **Review queue** | SM-2-calculated set of exercises due for review today |
| **Exercise** | A single practice item with a 30-second hard cap |
| **Lesson** | A focused teaching unit covering one Ruby concept, maximum 5 minutes |
| **Module** | A group of 5 thematically related lessons |
| **Lesson tree** | The full curriculum visualized as a graph with prerequisite dependencies |
| **SM-2** | Spaced repetition algorithm that schedules reviews based on recall success and interval |
| **Prerequisite** | A lesson that must be completed before another lesson unlocks |
| **Retention score** | SM-2-derived measure of how well a concept has been retained (0-100%) |
| **Calibrated content** | Content designed for experienced developers, omitting foundational programming concepts |
| **Idiomatic Ruby** | Ruby code written using Ruby-specific patterns, not translated from other languages |
