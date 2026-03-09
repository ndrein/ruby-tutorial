# ADR-006: Email Provider Selection

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)
**Feature**: email-notifications

---

## Context

The email-notifications feature sends at most one daily review reminder to Ana Folau. Volume: 1 email/day maximum, 365 emails/year. Constraints:
- Must be free (zero ongoing cost)
- Must be easy to configure and maintain (solo developer, personal tool)
- Must integrate cleanly with Rails 8 ActionMailer
- Single recipient (no marketing, no bulk sending, no list management)
- Self-hosted deployment (Docker Compose, on-premise)

Candidate services evaluated: Resend, Brevo (Sendinblue), Mailgun, SendGrid, Gmail SMTP, Postmark.

---

## Decision

**Resend** via ActionMailer SMTP adapter (or Resend HTTP API gem) as primary recommendation, with **Gmail SMTP** as the zero-account-required fallback.

**Primary: Resend**
- Free tier: 3,000 emails/month, 100/day — 100x needed volume
- Rails integration: `resend` gem (MIT license) or SMTP credentials
- Requires: one custom domain with DNS verification (SPF/DKIM)
- Deliverability: high (purpose-built for transactional email, modern infrastructure)
- Setup: ~15 minutes (DNS records + API key)

**Fallback: Gmail SMTP (if no custom domain available)**
- Cost: free (existing Google account)
- Rails integration: ActionMailer SMTP config only, no gem required
- Requires: Google account + App Password (2FA enabled)
- Deliverability: adequate for 1 recipient (self-to-self or known address)
- Limitation: 500 emails/day Google limit — irrelevant at 1/day

The architecture uses a `NotificationPort` driven port. The adapter implementation is swappable at configuration time — choosing between Resend and Gmail SMTP requires no domain code changes.

---

## Rationale

### Why Resend over Brevo

Brevo free tier: 300 emails/day, 9,000/month. Adequate. However:
- Brevo targets marketing/bulk email; interface designed for campaigns
- Resend targets transactional email for developers; significantly simpler API surface
- Resend's Rails DX is superior: single API key, no SMTP credential juggling

### Why Resend over Mailgun

Mailgun flex plan: 1,000 emails/month free (was previously more generous). Adequate but:
- Mailgun's free tier is time-limited (requires credit card after trial on some plans)
- Resend has no credit card requirement on free tier
- Resend has cleaner Rails documentation

### Why Resend over SendGrid

SendGrid free tier: 100 emails/day. Adequate. However:
- SendGrid's free tier requires credit card for verification
- SendGrid has had trust/reliability incidents (Twilio acquisition instability)
- Resend is simpler to configure and has superior developer experience

### Why Gmail SMTP as fallback (not as primary)

Gmail SMTP is free and requires no new account or domain. However:
- "From" address must be the Gmail account — reminder comes from user's own email
- No domain-level deliverability control (SPF/DKIM configured by Google, not user)
- App Password setup is less discoverable than API key
- Primary if user has no custom domain; otherwise Resend is superior

### Why not Postmark

Postmark has no free tier. Eliminated.

### Why not self-hosted SMTP (Mailhog/Postfix)

Adds operational burden (server, maintenance, spam filtering). Overkill for 1 email/day.

---

## Alternatives Considered

### Alternative 1: Brevo (Sendinblue)
- What: Free tier, 300 emails/day, SMTP + API, Ruby gem available
- Expected Impact: Functionally adequate; covers 1 email/day indefinitely
- Why Insufficient: Marketing-oriented product, more complex dashboard; worse Rails DX than Resend; no clear technical advantage for this use case

### Alternative 2: SendGrid
- What: Free tier, 100 emails/day, official `sendgrid-ruby` gem
- Expected Impact: Functionally adequate
- Why Insufficient: Credit card required for free tier; Twilio ownership creates uncertainty; Resend is simpler and has no credit card gate

### Alternative 3: Direct SMTP via Proton Mail or Fastmail
- What: Premium email providers allowing SMTP relay; personal account
- Expected Impact: Works for 1 email/day; good deliverability
- Why Insufficient: Requires paid subscription; contradicts free-tier requirement

---

## Consequences

**Positive (Resend path)**:
- Free indefinitely for this volume (3,000/month limit = 100x usage)
- No credit card required
- Excellent Rails/ActionMailer compatibility
- High deliverability (SPF/DKIM/DMARC out of the box)
- Swappable: port/adapter pattern means switching provider = adapter swap only

**Negative (Resend path)**:
- Requires custom domain with DNS access (SPF, DKIM records)
- External dependency: Resend API must be reachable from self-hosted server (internet egress on port 443)

**Positive (Gmail SMTP fallback)**:
- No domain required; works with existing Google account
- Zero cost, zero new accounts

**Negative (Gmail SMTP fallback)**:
- App Password required (extra setup step)
- "From" address is the Gmail address (less professional, acceptable for personal tool)
- Google may throttle or disable if flagged (unlikely at 1/day, but possible)

**Architectural consequence (both paths)**:
- `NotificationPort` driven port abstracts provider — domain code is provider-agnostic
- SMTP credentials stored in `config/credentials.yml.enc` (Rails encrypted credentials) — never in environment variables in source
- `at_most_once_per_day` invariant enforced in domain layer, not at provider level
