# ADR-004: SM-2 Implementation Strategy
**Status**: Accepted
**Date**: 2026-03-10

## Context

The SM-2 spaced repetition algorithm is the platform's core differentiator and primary product promise. Requirements specify the algorithm precisely (FR-2.1 through FR-2.9, NFR-5.1 through NFR-5.5):
- Exact formula: `EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))`
- EF clamped to [1.3, 2.5]
- Interval schedule: I(1)=1, I(2)=6, I(n)=round(I(n-1)*EF)
- Score < 3: reset interval to 1, repetitions to 0
- Quality score 0-5 derived from response time + correctness + hard flag
- Must be a pure function (no side effects, isolated, deterministic)
- Must have unit tests covering 7+ specified scenarios (NFR-5.5)

The algorithm is ~20 lines of logic. The architecture requires it as an isolated pure function — no Rails dependencies, no database access.

## Decision

**Hand-rolled Ruby service object (SM2Engine)**, not a third-party gem.

The implementation is two pure Ruby classes:
- `ScoreCalculator`: converts (answer_result, elapsed_seconds, hard_flag) → Integer(0-5)
- `SM2Engine`: converts SM2Input value object → SM2Result value object

Neither class requires inheritance, database access, or Rails dependencies.

## Consequences

**Positive**:
- Algorithm is exactly as specified in requirements — no third-party interpretation of SM-2 variants (there are multiple SM-2 variants; the spec precisely defines this one).
- Pure function: unit tests are fast, deterministic, require no fixtures or database setup.
- No external dependency: no version drift, no gem deprecation risk, no license compliance concern.
- ~20 lines of algorithm code; ~100 lines of test code. Easily audited.
- SM2Engine is the most mutation-tested component (kill rate gate applies directly).
- Crafter owns the internal structure — can implement as struct, class, or module; architecture only specifies the contract.

**Negative**:
- Requires writing and maintaining the algorithm. At ~20 lines with comprehensive tests, this is trivial maintenance overhead.

## Alternatives Considered

**`srs` gem (GitHub: kangguru/srs)**: Implements SM-2 in Ruby. Last significant update 2013; no active maintenance. Test coverage unknown. Would require wrapping to achieve pure function contract (gem expects database model integration). Rejected: maintenance risk; integration friction; algorithm spec may diverge from our exact requirements.

**`spaced_repetition` gem (various)**: Multiple gems exist with "spaced repetition" in the name. None are widely adopted, actively maintained, or specifically implement the published SuperMemo SM-2 algorithm with the exact formula in NFR-5.1. Rejected: none meet the purity or maintenance standards required.

**Anki's algorithm (SM-2 variant)**: Anki uses a modified SM-2. Requirements specify the published SuperMemo SM-2 (not Anki's variant). Rejected: wrong algorithm.
