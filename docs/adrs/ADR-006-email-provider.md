# ADR-006: Email Provider Selection
**Status**: Accepted
**Date**: 2026-03-10

## Context

The platform sends one daily transactional email per opted-in user (FR-4.1 through FR-4.8). Requirements:
- Delivery time accuracy: ±5 minutes of configured time (AC-009-01)
- No promotional content, click tracking, or marketing elements (FR-4.7)
- Delivery success rate ≥ 99% (NFR-2.3)
- Retry once on failure (AC-009-05)
- Single user: ≤ 31 emails/month
- Rails Action Mailer integration required
- Budget: $0 (free tier sufficient for MVP)
- Provider must be free-tier commercial (per OSS-first principle: email delivery is infrastructure, not software; no viable self-hosted alternative for production deliverability)

## Decision

**Postmark** (free tier: 100 emails/month, no time limit on trial).

`postmark-rails` gem provides a drop-in Action Mailer delivery method. Configuration is 3 lines.

## Consequences

**Positive**:
- Postmark's brand identity is "transactional email only" — explicitly does not support bulk marketing email. This structural alignment with FR-4.7 reduces configuration risk (no accidentally-enabled tracking features to turn off).
- Free tier: 100 emails/month indefinitely (not a time-limited trial). Single user sends ≤ 31 emails/month.
- Deliverability: Postmark consistently ranks in top tier for inbox placement. 99% delivery rate target (NFR-2.3) is achievable.
- Rails integration: `postmark-rails` gem is actively maintained, 2024 updates.
- Minimal configuration: API token only. No domain verification beyond sender signature.
- `deliver_later(wait_until:)` with Solid Queue: scheduled delivery at user's configured hour works natively.

**Negative**:
- Commercial service — not open source. No viable OSS alternative with equivalent deliverability. Accepted: email delivery as a service is the standard pattern; self-hosting (Postfix, etc.) would require significant operational overhead incompatible with the $5-20/month budget and single-operator constraint.
- If Postmark changes pricing or terms, migration to SendGrid/Mailgun requires changing one gem and one API token. Low migration cost.

## Alternatives Considered

**SendGrid (free tier: 100 emails/day)**: More generous free tier. However, SendGrid's dashboard and configuration surface expose bulk email features (click tracking, open tracking, unsubscribe management, marketing templates) that create risk of accidentally violating FR-4.7. Postmark's product design makes these violations impossible (no bulk email features). Rejected: higher misconfiguration risk.

**Mailgun (free tier: 100 emails/day for 3 months, then $35/month)**: Free tier expires after 3 months. Price jumps substantially. Rejected: unsustainable for a personal tool; pricing model mismatches the single-user use case.

**Amazon SES**: Extremely cheap at scale ($0.10/1000 emails). Free tier: 62,000 emails/month from EC2. Not usable from Fly.io without a paid AWS account with SES enabled in the relevant region. Configuration overhead is higher. Rejected: operational complexity disproportionate to need.

**Self-hosted (Postfix + DKIM/SPF/DMARC)**: Zero per-email cost. However: SPF/DKIM/DMARC configuration, IP warm-up, bounce handling, and deliverability monitoring are non-trivial operational tasks incompatible with the single-operator, $5-20/month constraint. Rejected: operational cost far exceeds the $0 savings.
