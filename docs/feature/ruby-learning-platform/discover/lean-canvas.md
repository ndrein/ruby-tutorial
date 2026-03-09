# Lean Canvas — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: 4 — Market Viability
**Gate**: G4
**Date**: 2026-03-08

---

## Lean Canvas

### 1. Problem (Phase 1 Validated)
Top 3 problems, confirmed through self-interview with behavioral evidence:

1. **Syntax transfer friction**: Existing Ruby learning tools (executeprogram.com, RubyMonk, Codecademy) are calibrated for beginners, wasting expert developers' time on concepts they already know.

2. **Habit failure via session overhead**: Learning tools requiring >15-minute sessions fail to sustain daily habits for working developers with fragmented attention budgets.

3. **Manual review burden**: Without automated spaced repetition, developers must self-select what to review — creating decision fatigue and inconsistent reinforcement.

**Existing alternatives and their gaps**:
- executeprogram.com: best SRS implementation, but content not expert-calibrated for Ruby
- Anki: best SRS algorithm, but no Ruby curriculum; requires manual card creation
- Exercism.io: strong content, no SRS, sessions too long, no daily queue automation

---

### 2. Customer Segments (by JTBD)

**Primary segment**: Experienced developers (2+ languages known) who want syntax-level Ruby fluency for professional use.

**Sub-segment 1 (MVP)**: Python or Java developer, learning Ruby for work or personal projects, values efficiency over depth, practices daily.

**Sub-segment 2 (post-MVP)**: Developer wanting Ruby + Rails fluency for web development; already has Ruby basics, needs idiomatic depth and Rails conventions.

**Segment by job-to-be-done, not demographics**:
- Job: "Acquire Ruby syntax fluency efficiently so I can write idiomatic code without documentation lookup"
- Not: "Junior developer learning to code"

**Early adopter profile**: Builder = user = primary early adopter. Single-user personal tool initially.

---

### 3. Unique Value Proposition

**Primary UVP**:
"Ruby syntax for developers who already know how to program — 15 minutes a day, spaced repetition drives the queue, no beginner hand-holding."

**Tagline candidate**: "Ruby for people who don't need Ruby explained."

**Differentiation stack**:
1. Expert-calibrated content (no beginner scaffolding) — content differentiator
2. SM-2 automates daily queue — removes decision fatigue
3. 15-minute daily session hard cap — structural habit enabler
4. Keyboard-native interface — developer experience differentiator

---

### 4. Solution (Top 3 Features for Top 3 Problems)

| Problem | Solution Feature |
|---------|----------------|
| Syntax transfer friction | Expert-calibrated 25-lesson curriculum (Python/Java-to-Ruby mapping, no basics) |
| Habit failure | SM-2 review engine + 15-min session cap + daily email with pre-built queue |
| Manual review burden | Automated SM-2 scheduling — user never selects what to review |

**Supporting features**:
- Keyboard-native UI (vim-style shortcuts, high-contrast focus states)
- Progress dashboard (mastery counts, retention rate, streak)
- Rails extension track (post-MVP)

---

### 5. Channels

**Personal tool context**: Channels are not distribution challenges — this is a single-user personal tool.

**If product grows to multi-user**:
- Organic: developer blog posts ("I built X to learn Ruby"), HN/Reddit (r/ruby, r/learnprogramming)
- Direct: word of mouth within developer communities
- Content: lessons as shareable assets (individual lesson pages indexable)
- No paid acquisition in MVP; CAC = $0 by design

**Validated channel**: Direct use by builder. Post-MVP channels require separate discovery if product expands.

---

### 6. Revenue Streams

**MVP (personal tool)**: $0 revenue — this is a personal learning tool, not a commercial product initially.

**If multi-user product**:

| Model | Description | Precedent |
|-------|-------------|-----------|
| One-time purchase | Pay once, access all content | executeprogram.com (subscription) |
| Subscription | Monthly/annual access | $9-19/month (market rate for SRS tools) |
| Freemium | Free up to N lessons, paid for full catalog | Common for learning tools |

**Viability note for personal tool**: Unit economics are not relevant for single-user personal tool. If product grows, revenue model requires a separate discovery cycle. This is explicitly out of scope for MVP.

---

### 7. Cost Structure

**MVP personal tool costs**:

| Cost | Type | Estimate |
|------|------|----------|
| Developer time (builder = user) | Opportunity cost | 40-80 hours to build MVP |
| Hosting (Heroku/Railway/Fly.io) | Recurring | $5-20/month |
| Email delivery (SendGrid/Postmark free tier) | Recurring | $0 (free tier sufficient for 1 user) |
| Domain | One-time | ~$12/year |
| **Total cash cost** | | ~$100-240/year |

**Feasibility**: Extremely low cost structure. Personal tool economics are not a viability risk.

---

### 8. Key Metrics

**Leading indicators (behavior)**:
- Daily session completion rate (target: 5+/7 days per week)
- Average session duration (target: <=15 min)
- Exercises completed per week
- SM-2 review queue completion rate (did user complete the queue today?)

**Lagging indicators (outcome)**:
- Retention rate per concept at 7/14/30 days (SM-2 effectiveness)
- Lesson completion rate (progressing through curriculum)
- Time-to-first-correct-answer on review (fluency proxy)

**Anti-metric** (signals the tool is failing):
- Session duration consistently >20 min (sessions are too long)
- Review queue skip rate >30% (queue feels irrelevant or burdensome)
- Lesson completion stalls (curriculum not engaging)

---

### 9. Unfair Advantage

**For personal tool**: The advantage is that it is built by the exact target user — content calibration is perfect because the builder knows exactly what an expert developer does and does not need.

**If product grows**:
- Content quality moat: Expert-calibrated curriculum is difficult for general-purpose tools to replicate without targeting the segment intentionally
- Keyboard-native UX: Most EdTech is built for general audiences; developer-specific UX is a genuine differentiator
- Community signal: If built in public, early community around "learning tools for developers, by developers"

---

## 4 Big Risks Assessment

### Risk 1: Value Risk
**Question**: Will the user actually use this daily and find value?

**Evidence**: Builder = user; building it = high commitment signal. Daily 15-min constraint is derived from lived experience. SM-2 is research-backed for retention.

**Residual risk**: H1 (habit sustainability) unvalidated. Requires 2-week post-launch trial.

**Status**: YELLOW — proceed with 2-week validation plan post-launch

**Hypothesis**: If user misses 3+ consecutive days in week 2, re-evaluate session length or notification design.

---

### Risk 2: Usability Risk
**Question**: Can the user actually use this tool efficiently?

**Evidence**: Keyboard map fully specified. Exercise types validated (30-sec budget achievable). Lesson length achievable (expert content is denser, shorter). Focus states planned.

**Residual risk**: SM-2 intervals may need tuning for expert-pace learners (faster mastery = shorter intervals needed).

**Status**: GREEN — usability specification is complete; SM-2 tuning is a post-launch iteration

---

### Risk 3: Feasibility Risk
**Question**: Can we build this?

**Evidence**: All components are standard, well-understood technology:
- SM-2 algorithm: published, reference implementations exist in Ruby/Rails
- Email delivery: SendGrid/Postmark API
- In-browser exercises: HTML + JavaScript (fill-in-the-blank, multiple choice)
- Keyboard nav: Standard browser focus management
- Database: PostgreSQL with exercise/concept/review tables

**No novel engineering required.** Biggest feasibility risk is content production (25 lessons = ~12 hours of writing).

**Status**: GREEN

---

### Risk 4: Viability Risk
**Question**: Does this work as a business?

**For personal tool**: Not applicable — this is not a commercial product. Cost is <$250/year. Builder derives value as the user. No business model required for MVP.

**If expanded**: Viability requires separate discovery cycle. The market exists (executeprogram.com revenue-positive, Exercism has donors, Codecademy IPO'd). Developer education is a validated market. The expert-calibrated niche is underserved but small.

**Status**: GREEN for personal tool; YELLOW for commercial expansion (future discovery needed)

---

## G4 Gate Evaluation

### Pre-Gate: All Phases Complete

- [x] G1: Problem validated — 8 behavioral signals, >60% confirmation, customer words captured
- [x] G2: Opportunities prioritized — OST complete, top 3 scored >8 (16, 15, 15), all job steps covered
- [x] G3: Solution tested — all hypotheses evaluated, keyboard spec complete, content spike complete
- [x] G4: Viability confirmed — Lean Canvas complete, 4 risks assessed

### G4 Criteria

| Criterion | Target | Result | Status |
|-----------|--------|--------|--------|
| Lean Canvas complete | All 9 boxes filled | Yes | PASS |
| Four big risks addressed | All green/yellow | Value=YELLOW, Usability=GREEN, Feasibility=GREEN, Viability=GREEN | PASS |
| Channel validated | 1+ viable | Direct use by builder (personal tool) | PASS |
| Unit economics | LTV > 3x CAC (if commercial) | N/A for personal tool; cost <$250/year | PASS |
| Go/no-go documented | Required | GO — see below | PASS |

### Go / No-Go Decision

**Decision: GO**

**Rationale**:
1. Problem is real and validated (behavioral evidence, not opinion)
2. Competitive gap exists and is unoccupied for the target segment
3. Solution concept is fully specified and technically straightforward
4. Cost is trivial; risk is time investment only
5. Builder = user = highest commitment signal; no market risk for personal tool

**Post-launch validation commitments** (not blockers, but required for iteration 2):
- Track daily session completion for 2 weeks (H1 validation)
- Track SM-2 correct-answer rate at review time (H5 validation)
- Measure actual session duration vs. 15-min target

**Kill criteria** (if these emerge post-launch, revisit product):
- Average session duration >20 min after 2 weeks of use
- User skips review queue >3 consecutive days in week 2
- SM-2 intervals feel wildly wrong (all reviews too easy or all too hard)

---

## Handoff Summary

All four phases complete. All four gates passed. Discovery package ready for product-owner DISCUSS wave.

**Core validated insight**: An experienced developer (Python/Java) learning Ruby needs expert-calibrated content, automated spaced repetition, and a 15-minute daily session cap — none of which are fully provided by any single existing tool.

**Product to build**: Personal Ruby syntax learning platform with SM-2, 25 expert-calibrated lessons, 30-second review exercises, daily email queue, and keyboard-native UI.
