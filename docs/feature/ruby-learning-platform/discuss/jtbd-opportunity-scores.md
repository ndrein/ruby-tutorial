# JTBD Opportunity Scores — Ruby Learning Platform

## Overview

Opportunity scores derived from DISCOVER wave interviews and team estimation. Single user = Ana Folau (persona), team-estimated ratings treated as directional signals. Scores using Ulwick's formula: Importance + max(0, Importance - Satisfaction).

**Data Quality**: Single-user product (personal tool). Scores based on discovery interview data treated as Importance proxy; current-solution satisfaction based on ad-hoc learning approach.

---

## Opportunity Scoring Matrix

### Area: Core Learning Flow

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 1 | Minimize the time spent on content that maps to concepts already mastered in Python/Java | 95 | 15 | 18.0 | Extremely Underserved |
| 2 | Minimize the cognitive effort required to decide what to study each session | 90 | 10 | 17.0 | Extremely Underserved |
| 3 | Minimize the likelihood of learning sessions exceeding 15 minutes | 90 | 20 | 16.0 | Extremely Underserved |
| 4 | Maximize the likelihood that Ruby syntax is retained across sessions | 85 | 20 | 15.0 | Extremely Underserved |
| 5 | Minimize the time to understand how a Ruby concept differs from Python/Java equivalent | 85 | 25 | 14.5 | Underserved |
| 6 | Maximize the likelihood of completing a practice session on any given day | 80 | 30 | 13.0 | Underserved |

### Area: Navigation and UI

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 7 | Minimize the time to navigate between exercises without leaving the keyboard | 75 | 20 | 13.0 | Underserved |
| 8 | Minimize the likelihood of needing a mouse for any learning interaction | 75 | 15 | 13.5 | Underserved |
| 9 | Minimize the number of clicks/keystrokes to begin today's session | 70 | 35 | 10.5 | Appropriately Served |

### Area: Progress and Curriculum Visibility

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 10 | Maximize the clarity of which lessons are completed, available, and locked | 80 | 15 | 14.5 | Underserved |
| 11 | Minimize the time to understand why a lesson is locked | 75 | 10 | 14.0 | Underserved |
| 12 | Maximize the likelihood of knowing how many sessions remain to cover the full curriculum | 65 | 10 | 12.0 | Underserved |
| 13 | Minimize the likelihood that progress metrics feel gamified or hollow | 70 | 20 | 12.0 | Underserved |

### Area: Topic Selection and Lesson Tree

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 14 | Minimize the time to find and select a specific Ruby topic by name | 70 | 20 | 12.0 | Underserved |
| 15 | Maximize the clarity of prerequisite dependencies between lessons | 80 | 10 | 15.0 | Extremely Underserved |
| 16 | Minimize the likelihood of attempting a lesson without required prerequisite knowledge | 75 | 25 | 12.5 | Underserved |
| 17 | Maximize the ability to preview a locked lesson's content before deciding to unlock | 60 | 5 | 11.5 | Appropriately Served |

### Area: SM-2 Review Engine

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 18 | Minimize the likelihood of forgetting a previously learned concept | 90 | 15 | 16.5 | Extremely Underserved |
| 19 | Minimize the time to complete a review exercise | 80 | 30 | 13.0 | Underserved |
| 20 | Maximize the accuracy of SM-2 scheduling relative to actual recall difficulty | 85 | 10 | 16.0 | Extremely Underserved |
| 21 | Minimize the likelihood of over-scheduling reviews on any single day | 70 | 20 | 12.0 | Underserved |

### Area: Onboarding

| # | Outcome Statement | Imp. (%) | Sat. (%) | Score | Priority |
|---|-------------------|----------|----------|-------|----------|
| 22 | Minimize the time from first launch to first meaningful exercise | 85 | 15 | 15.5 | Extremely Underserved |
| 23 | Maximize the clarity of what the learning system expects of the user on day 1 | 80 | 20 | 14.0 | Underserved |
| 24 | Minimize the likelihood of confusion about where to start in the curriculum | 85 | 20 | 14.5 | Underserved |

---

## Top Opportunities (Score >= 14)

| Rank | Outcome | Score | Maps To |
|------|---------|-------|--------|
| 1 | Minimize time on already-known content | 18.0 | US-06 (Lesson Content Standards) |
| 2 | Minimize cognitive effort deciding what to study | 17.0 | US-05 (SM-2 Review Engine) |
| 3 | Maximize SM-2 scheduling accuracy | 16.5 | US-05 (SM-2 Review Engine) |
| 4 | Minimize sessions exceeding 15 minutes | 16.0 | US-02 (Daily Session Flow) |
| 5 | Maximize SM-2 retention across sessions | 15.0 | US-05 (SM-2 Review Engine) |
| 6 | Maximize prerequisite clarity | 15.0 | US-08 (Lesson Tree Navigation) |
| 7 | Minimize time from first launch to first exercise | 15.5 | US-01 (Onboarding) |
| 8 | Minimize time understanding Python/Java to Ruby mapping | 14.5 | US-06 (Lesson Content Standards) |
| 9 | Maximize clarity of completed/available/locked lessons | 14.5 | US-09 (Progress Dashboard) |
| 10 | Minimize confusion about where to start | 14.5 | US-01 (Onboarding) |
| 11 | Minimize time to understand why a lesson is locked | 14.0 | US-08 (Lesson Tree Navigation) |
| 12 | Maximize clarity on day 1 expectations | 14.0 | US-01 (Onboarding) |

---

## Overserved Areas (Score < 10)

No outcomes scored below 10. This is consistent with a greenfield product with no existing solution — satisfaction is uniformly low across all outcome statements. There are no simplification candidates at this stage.

---

## Scoring Method Notes

- **Importance**: Estimated from discovery interview language ("critical", "daily pain" = 90-95%; "nice to have" = 60-70%)
- **Satisfaction**: Based on current ad-hoc learning approach (documentation + Stack Overflow + tutorials)
- **Source**: Single user (Ana Folau), discovery interview from DISCOVER wave. Treat as directional, not statistically significant.
- **Confidence**: MEDIUM — strong signal from single motivated user but not validated across multiple learners.

---

## Topic Selection and Lesson Tree Deep Scores

These two features required specific scoring per the task brief.

### Topic Selection (User-Initiated Override)

| Outcome | Imp. | Sat. | Score | Priority |
|---------|------|------|-------|----------|
| Minimize time to find specific topic by name | 70 | 20 | 12.0 | Underserved |
| Minimize friction when navigating to a non-sequential topic | 65 | 15 | 11.5 | Appropriately Served |
| Minimize likelihood of losing SM-2 progress by jumping ahead | 70 | 30 | 11.0 | Appropriately Served |
| Maximize discoverability of topics available for immediate study | 60 | 20 | 10.0 | Appropriately Served |

**Summary**: Topic selection scores in the 10-12 range — appropriately served to underserved. It is a "Should Have" feature, not "Must Have." SM-2 automation (scores 16-17) is the primary mechanism; topic selection is a valuable escape hatch.

### Lesson Tree / Prerequisite Graph

| Outcome | Imp. | Sat. | Score | Priority |
|---------|------|------|-------|----------|
| Maximize clarity of prerequisite dependencies | 80 | 10 | 15.0 | Extremely Underserved |
| Minimize time to understand what unlocks next | 75 | 10 | 14.0 | Underserved |
| Minimize likelihood of attempting lesson without prerequisites | 75 | 25 | 12.5 | Underserved |
| Maximize visual legibility of curriculum structure | 70 | 15 | 12.5 | Underserved |

**Summary**: Lesson tree scores 12-15 — underserved to extremely underserved. This is a "Must Have" for MVP. The prerequisite graph must be explicit and educational, not just a gate.
