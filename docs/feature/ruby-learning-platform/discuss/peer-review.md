review_id: "req_rev_20260309_080000"
reviewer: "product-owner (review mode)"
artifact: "docs/feature/ruby-learning-platform/discuss/user-stories.md + acceptance-criteria.md"
iteration: 1

---

# Peer Review — Ruby Learning Platform Requirements

## Strengths

- **Expert calibration is concrete and testable**: The "no beginner scaffolding" principle is operationalized as a specific acceptance criterion (AC-06-03: no exercise explains what a variable, loop, or OOP concept is), not just a statement of intent.
- **SM-2 algorithm is fully specified**: Business rules BR-07 and BR-08 are expressed with exact formulas (new_interval = max(1, prev * ef), ef -= 0.2, min 1.3), making implementation unambiguous.
- **Shared artifacts tracked rigorously**: The shared-artifacts-registry.md documents 12 artifacts with sources, consumers, and integration risks. HIGH-risk artifacts (prerequisite_graph, next_lesson_title) have explicit consistency checkpoints.
- **No force-skip mechanism is explicit**: AC-03-07 states "No 'skip prerequisite' option exists anywhere in the UI" — a decision captured as a testable absence.
- **Anti-gamification is enforced by AC**: AC-09-04 tests element absence ("no badges, XP, levels, points, or achievement language"), not just intent.
- **Domain examples use real data**: Ana Folau (not "user123"), concrete lesson numbers, specific SM-2 values (ease_factor 2.5, interval 2 days → new interval 5 days).

---

## Issues Identified

### Confirmation Bias

**No critical confirmation bias detected.**

Minor: The 30-second exercise cap is stated as "no exceptions" but there is no scenario testing what happens when Ana is typing and hits 30 seconds exactly (mid-keystroke). The timer expiry scenario covers non-submission, but the "in-progress submission" edge case is unspecified.
- Severity: LOW
- Location: AC-04-03, journey-onboarding.feature timer scenarios
- Recommendation: Add note in AC-04 that mid-keystroke timer expiry submits the partial answer (treated as incorrect) rather than discarding it. This is a product decision, not a gap in the story.

### Completeness Gaps

**Gap 1: Lesson content validation — who reviews the 75 exercises?**
- Issue: US-06 assigns content authoring as the primary work. There is no specified acceptance criterion for content quality review (correctness of Ruby syntax in example code).
- Severity: HIGH
- Location: US-06 AC-06-04
- Recommendation: Add acceptance criterion: "All 75 exercise code examples pass Ruby parser validation (e.g., `ruby -c`)." This is automatable and closes the gap.

**Gap 2: Single-user data loss scenario not covered by a scenario**
- Issue: The risk register notes that localStorage/IndexedDB may be cleared by the browser. This is documented as a risk but there is no acceptance criterion specifying what the user sees when storage is empty (after previous sessions).
- Severity: MEDIUM
- Location: US-05 Technical Notes, risk register
- Recommendation: Add one scenario: "Given Ana has completed 10 sessions. When browser storage is cleared. Then the platform launches in first-time mode with all progress reset. And a recoverable state warning is shown on first launch." This is the expected behavior, not a fix — just needs to be explicit.

**Gap 3: Partial SM-2 answer type not defined in UI**
- Issue: US-05 Technical Notes say "Partial maps to incorrect for SM-2 purposes" but no story defines when an answer is classified as Partial vs. Incorrect. Is Partial a user-selectable self-rating, or system-detected?
- Severity: MEDIUM
- Location: US-05 Technical Notes
- Recommendation: Clarify: is "Partial" a system classification (Ana's answer contains some correct elements) or a user self-assessment button? If the latter, add a scenario. If the former, define the detection criteria. For MVP, simplest is to remove "Partial" and have only Correct / Incorrect / Skipped / Missed.

### Clarity Issues

**Clarity Issue 1: "Sessions remaining" estimate formula is ambiguous**
- Issue: US-09 Technical Notes say "pending_lessons / avg_lessons_per_session (rolling 7-day average)." But early in practice, the 7-day rolling average is based on very few sessions (or zero). What is the estimate when < 7 sessions completed?
- Severity: LOW
- Location: US-09 Technical Notes, AC-09 (not addressed)
- Recommendation: Specify default: "If fewer than 7 sessions completed, use observed session count / days elapsed. If zero sessions, show 'Complete one session to see estimate.'"

### Testability Concerns

**No critical testability issues.** All acceptance criteria are stated as observable user outcomes or measurable system states. The @property Gherkin scenarios correctly tag ongoing qualities.

**Minor concern**: AC-08-05 ("prerequisite graph is acyclic") is a structural property tested once at load time. The @property tag is appropriate but the scenario should be more specific about when the test runs.
- Severity: LOW
- Location: AC-08-05, journey-topic-selection.feature @property
- Recommendation: Add trigger: "Given the application loads. When the curriculum data is initialized. Then the prerequisite graph traversal finds no cycles." This makes it a standard integration test.

### Priority Validation

- Q1 (Largest bottleneck?): YES. Opportunity scores 16-18 for SM-2 automation, expert calibration, and session discipline directly drive all Must Have stories.
- Q2 (Simpler alternatives?): ADEQUATE. US-10 (email notifications) explicitly deferred post-MVP with rationale. Rails extensibility (OPP-6, score 7) explicitly excluded.
- Q3 (Constraint prioritization?): CORRECT. 15-minute cap and 30-second exercise cap are user-validated constraints (from discovery wave), not internal assumptions.
- Q4 (Data-justified?): JUSTIFIED. Opportunity scores from discovery interview ground the MoSCoW decisions. Confidence noted as MEDIUM (single user) — appropriate hedging.

**Priority Validation Verdict: PASS**

---

## Approval Status

**approval_status: approved**

**Resolution**: All three MEDIUM/HIGH gaps resolved in same pass:
- AC-06-05 added (Ruby + Python syntax validation as CI check)
- AC-05-09 added (storage-cleared first-launch behavior)
- "Partial" answer type removed from US-05 MVP scope (simplified to correct/incorrect/skipped/missed)

**Original condition (for record)**: Resolve the three MEDIUM/HIGH gaps before DESIGN wave handoff:
1. Add AC-06-05: Ruby syntax validation for all 75 exercise code examples
2. Add explicit scenario for storage-cleared first-launch behavior (US-05 or US-01)
3. Clarify or remove "Partial" answer type from SM-2 spec (US-05)

The LOW severity items (timer mid-keystroke, sessions-remaining formula, @property trigger) may be resolved in the DESIGN wave or at implementation time.

**critical_issues_count: 0**
**high_issues_count: 1** (Gap 1: lesson content validation criterion)
**medium_issues_count: 2** (Gap 2: storage cleared scenario; Gap 3: Partial answer type)
**low_issues_count: 3**

---

## Remediation Actions Required Before DESIGN Handoff

### Action 1: Add AC-06-05
In acceptance-criteria.md, under AC-06, add:
> AC-06-05 | All 75 exercise code examples (Python/Java and Ruby) pass syntax validation via automated parser check | Yes — automatable | Content authoring standard

### Action 2: Add storage-cleared scenario
In user-stories.md US-05 (or US-01), add domain example 4:
> "Storage cleared: Ana opens the platform after browser storage is cleared. Platform launches in first-time mode. A notice reads: 'No previous progress found. Starting fresh.' Ana begins as a new user."

Add corresponding AC: "When storage is empty on launch (no prior sessions found), the platform launches in first-time onboarding mode."

### Action 3: Clarify or remove Partial answer type
Decision required: is "Partial" a user self-rating or system-detected?
- If removing: update US-05 Technical Notes to remove "partial" from result types. Update SM-2 AC to only list: correct / incorrect / skipped / missed.
- If keeping: add scenario defining when Partial is triggered and what the feedback screen shows.
