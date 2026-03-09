# Email Infrastructure — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Scope**: Operational notification emails (health alerts) + Action Mailer foundation for future in-app email

---

## Overview

Email serves two purposes in this system:

1. **Operational alerts**: Notify the operator when the application is unhealthy (health check failure). Supplements the Docker Compose health check and cron script described in `monitoring-alerting.md`.
2. **Rails Action Mailer foundation**: Rails is configured for email from day one so that future in-app use (e.g., study reminders) requires only adding mailer classes, not infrastructure changes.

The strategy is environment-specific:
- **Development**: Mailpit — local mail catcher that captures all outgoing email. Zero configuration. No real email sent.
- **Production**: External SMTP — operator provides credentials via environment variables. Provider-agnostic.

---

## Development: Mailpit

[Mailpit](https://mailpit.axllent.org/) is a lightweight local SMTP server with a web UI that captures all outgoing email without delivering it. It replaces the older Mailcatcher.

### Docker Compose integration

Add to `docker-compose.yml`:

```yaml
  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "1025:1025"   # SMTP (for Rails Action Mailer)
      - "8025:8025"   # Web UI (http://localhost:8025)
    environment:
      MP_MAX_MESSAGES: 100
      MP_DATA_FILE: /data/mailpit.db
    volumes:
      - mailpit_data:/data
```

Add volume:
```yaml
volumes:
  mailpit_data:
```

### Rails Action Mailer configuration (development)

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "localhost",
  port: 1025,
}
config.action_mailer.raise_delivery_errors = false
config.action_mailer.perform_deliveries = true
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
```

### Accessing Mailpit UI

From the host machine: `http://localhost:8025`

All emails sent by Rails in development are captured here. No emails reach external recipients.

---

## Production: External SMTP

Production email is delivered via an external SMTP provider. The configuration is provider-agnostic — the operator supplies credentials through environment variables.

Recommended free-tier options for a personal tool:
- **Gmail SMTP** (with App Password if 2FA is enabled)
- **Fastmail** (if already subscribed)
- **Brevo (Sendinblue)** — 300 emails/day free
- **Resend** — 3,000 emails/month free

### Rails Action Mailer configuration (production)

```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV.fetch("SMTP_HOST"),
  port: ENV.fetch("SMTP_PORT", 587).to_i,
  domain: ENV.fetch("SMTP_DOMAIN", "localhost"),
  user_name: ENV.fetch("SMTP_USERNAME"),
  password: ENV.fetch("SMTP_PASSWORD"),
  authentication: :plain,
  enable_starttls_auto: true,
}
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.default_url_options = {
  host: ENV.fetch("APP_HOST", "localhost"),
  port: ENV.fetch("APP_PORT", 3000).to_i,
}
```

### Environment variables

Add to `.env.example`:

```bash
# Email (production)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=your-address@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=ruby-learning-platform@example.com
ALERT_EMAIL_TO=your-address@example.com

# App URL (used in mailer links)
APP_HOST=localhost
APP_PORT=3000
```

---

## Operational Alert: Health Check Email

The health check cron script in `monitoring-alerting.md` is extended to send an email when the health check fails. This uses the `mail` CLI utility (available on most Linux distributions as part of `mailutils` or `s-nail`).

### Updated health check script

```bash
#!/usr/bin/env bash
# /opt/ruby-learning-platform/scripts/health-check.sh
# Run via cron: */5 * * * * /opt/ruby-learning-platform/scripts/health-check.sh

set -euo pipefail

HEALTH_URL="http://localhost:3000/health"
LOG_FILE="/var/log/ruby-learning-platform/health.log"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
ALERT_EMAIL="${ALERT_EMAIL_TO:-}"
ALERT_SUBJECT="[Ruby Learning Platform] Health check failed"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${HEALTH_URL}" || echo "000")

if [ "${HTTP_STATUS}" = "200" ]; then
  echo "${TIMESTAMP} OK (${HTTP_STATUS})" >> "${LOG_FILE}"
else
  echo "${TIMESTAMP} DEGRADED (${HTTP_STATUS})" >> "${LOG_FILE}"

  # Send email alert if ALERT_EMAIL_TO is configured and mail is available
  if [ -n "${ALERT_EMAIL}" ] && command -v mail &>/dev/null; then
    echo "Health check failed at ${TIMESTAMP}. HTTP status: ${HTTP_STATUS}. Check: docker compose ps" \
      | mail -s "${ALERT_SUBJECT}" "${ALERT_EMAIL}"
  fi

  # Fallback: desktop notification if running on local machine with notify-send
  if command -v notify-send &>/dev/null; then
    notify-send "Ruby Learning Platform" "Health check failed: HTTP ${HTTP_STATUS}"
  fi
fi
```

Install `mail` on the host:
```bash
# Debian/Ubuntu
sudo apt-get install -y mailutils

# Arch Linux
sudo pacman -S s-nail
```

Configure the host's mail transfer agent to relay through your SMTP provider, or use a minimal `msmtp` configuration:

```bash
# /etc/msmtprc (msmtp — lightweight SMTP relay for scripts)
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host           smtp.gmail.com
port           587
from           your-address@gmail.com
user           your-address@gmail.com
password       your-app-password
```

```bash
# Install msmtp and configure mail to use it
sudo apt-get install -y msmtp msmtp-mta
# msmtp-mta sets /usr/sbin/sendmail -> msmtp, so `mail` and Rails sendmail adapter both work
```

---

## Application Mailer Base Class

The Rails mailer base class is set up even if no mailers exist yet. This ensures the infrastructure is exercised at boot and misconfiguration is caught early.

```ruby
# app/mailers/application_mailer.rb

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_FROM", "noreply@ruby-learning-platform.local")
  layout "mailer"
end
```

---

## Test Configuration

In the test environment, Action Mailer uses `:test` delivery so emails are captured in `ActionMailer::Base.deliveries` without requiring a running SMTP server.

```ruby
# config/environments/test.rb
config.action_mailer.delivery_method = :test
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
```

---

## Gem Dependencies

No additional gems are required. Action Mailer ships with Rails. No `letter_opener` or `mail_interceptor` gem is needed because Mailpit handles dev email capture at the SMTP level (provider-agnostic, works for all outgoing email regardless of how it's sent).

---

## Service Topology Update

Mailpit adds one development-only service to the Docker Compose topology:

```
┌──────────────────────────────────────────────────────────────────┐
│  Docker Compose (development)                                    │
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌──────────────────────┐  │
│  │    app      │   │   jaeger    │   │       mailpit        │  │
│  │ Rails/Puma  │──►│  OTLP UI    │   │  SMTP :1025          │  │
│  │  port 3000  │   │  port 16686 │   │  Web UI :8025        │  │
│  └──────┬──────┘   └─────────────┘   └──────────────────────┘  │
│         │ SMTP ──────────────────────────────────────────────►  │
│         │ SQL                                                    │
│         ▼                                                        │
│  ┌─────────────┐   ┌─────────────┐                              │
│  │     db      │   │    redis    │                              │
│  │  PostgreSQL │   │   Redis 7   │                              │
│  └─────────────┘   └─────────────┘                              │
└──────────────────────────────────────────────────────────────────┘
```

Mailpit is **development-only**. Production uses external SMTP directly. There is no `mailpit` service in `docker-compose.prod.yml`.

---

## Future: Study Session Reminders

When study session reminder emails are added as a feature, the infrastructure is ready:

1. Create `app/mailers/session_reminder_mailer.rb` (subclass `ApplicationMailer`)
2. Create email templates in `app/views/session_reminder_mailer/`
3. Schedule via a Sidekiq job (post-MVP) or a cron entry calling `rails runner`

The only environment change needed is ensuring `SMTP_*` variables are set in `.env.prod`.
