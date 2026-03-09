# Monitoring and Alerting — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Context**: Single-user personal tool, self-hosted, one developer operates it

---

## SLO Design Philosophy

SLOs for a personal tool differ from multi-user production systems. There is no external SLA, no on-call rotation, no error budget burning through customer complaints. SLOs serve two purposes here:

1. **Operational awareness**: Know when the system is degraded so the session isn't silently broken.
2. **Quality benchmarks**: Prevent performance regression as features are added.

SLOs are therefore conservative (realistic for a personal tool) and alerting is passive (log and surface, not page).

---

## Service Level Indicators (SLIs)

SLIs measure what the user actually experiences.

### SLI-1: Request Success Rate

```
SLI = successful_requests / total_requests * 100

successful_request = HTTP response in [200, 201, 302, 304]
failed_request     = HTTP response in [5xx]
excluded           = 4xx client errors (not a system failure)
```

### SLI-2: Session Dashboard Latency

```
SLI = requests_with_duration_under_500ms / total_session_dashboard_requests * 100

Measured at: GET /session (Rails controller span duration)
```

### SLI-3: Exercise Feedback Latency

```
SLI = requests_with_duration_under_100ms / total_exercise_result_requests * 100

Measured at: POST /exercises/:id/results (Turbo Frame partial re-render)
```

### SLI-4: SM-2 Queue Computation Latency

```
SLI = computations_under_200ms / total_session_plan_computations * 100

Measured at: session.fetch_review_queue span (domain operation, not full HTTP)
```

### SLI-5: Application Availability

```
SLI = successful_health_checks / total_health_checks * 100

GET /health returns 200 with {"status": "ok"}
Checked every 30 seconds by Docker Compose healthcheck
```

---

## Service Level Objectives (SLOs)

Calibrated for a personal tool: aspirational but not punitive.

| SLO | Target | Measurement window | Rationale |
|-----|--------|--------------------|-----------|
| SLO-1: Request success rate | >= 99% | Rolling 7 days | 1% failure = ~1.7 min/day of broken requests. Acceptable for personal use. |
| SLO-2: Session dashboard p95 <= 500ms | >= 95% of requests | Rolling 7 days | Architecture target. Redis cache should achieve this consistently. |
| SLO-3: Exercise feedback p95 <= 100ms | >= 95% of requests | Rolling 7 days | Turbo Frame re-render. CPU-bound, not DB-bound. |
| SLO-4: SM-2 queue p95 <= 200ms | >= 95% of computations | Rolling 7 days | 12-row PostgreSQL index scan. Should be well under target. |
| SLO-5: Application availability | >= 99% | Rolling 7 days | ~1.7 min/day downtime acceptable for personal tool. |

Error budgets (weekly):

| SLO | Error budget/week |
|-----|-------------------|
| SLO-1 | 1.7 min of failed requests |
| SLO-2 | 21 min of slow dashboard loads (5% of sessions) |
| SLO-5 | 1.7 min of downtime |

---

## Health Check Endpoint

The `/health` endpoint (defined in observability-design.md) is the primary liveness and readiness signal.

### Response schema

```json
{
  "status": "ok",
  "checks": {
    "database": true,
    "redis": true
  },
  "timestamp": "2026-03-09T14:30:00.000Z",
  "version": "1.0.0"
}
```

Degraded response (HTTP 503):

```json
{
  "status": "degraded",
  "checks": {
    "database": false,
    "redis": true
  },
  "timestamp": "2026-03-09T14:30:00.000Z",
  "version": "1.0.0"
}
```

### Docker Compose integration

Docker Compose marks the `app` container as `unhealthy` if `/health` returns non-200 or times out. Dependent services (worker, if enabled) will not start until `app` is healthy.

```yaml
# From docker-compose.prod.yml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

---

## Alerting Strategy

A single-user personal tool has no on-call rotation and no third-party alerting service. Alerting must be useful without being noisy. The strategy is:

**Primary mechanism**: Structured logs surfaced in Jaeger + local log file review.
**Secondary mechanism**: Docker Compose health status (`docker compose ps` shows `healthy`/`unhealthy`).
**Tertiary mechanism**: Cron-based health check script on the host with email notification (see `email-infrastructure.md`).

### Alerting tiers (adapted for personal tool)

| Tier | Condition | Response | Mechanism |
|------|-----------|----------|-----------|
| Critical | App container unhealthy (3 consecutive health check failures) | Investigate and restart | Docker Compose restart policy + email alert via cron health check |
| Warning | Database or Redis unreachable (health check degraded) | Restart affected service | `docker compose ps`; `docker compose restart db` |
| Info | Response time SLO degraded over 7-day window | Review recent changes; check Jaeger traces | Weekly manual review of Jaeger traces |

### Host-level health check cron with email alert

Runs every 5 minutes. Sends an email when the health check fails. See `email-infrastructure.md` for the full script and SMTP setup.

```bash
# Cron entry
*/5 * * * * ALERT_EMAIL_TO=your@email.com /opt/ruby-learning-platform/scripts/health-check.sh
```

The script logs to `/var/log/ruby-learning-platform/health.log` and emails `ALERT_EMAIL_TO` on any non-200 response.

---

## Key Metrics to Monitor

These are observable from Jaeger traces and structured logs without a dedicated metrics backend. A future enhancement could introduce Prometheus + Grafana, but this is deferred as the tool is foundational.

### Application metrics (from Jaeger traces)

| Metric | How to observe | Threshold to watch |
|--------|---------------|-------------------|
| Session dashboard P95 latency | Filter `GET /session` spans in Jaeger | > 500ms |
| Exercise feedback P95 latency | Filter `POST /exercises/:id/results` spans | > 100ms |
| SM-2 compute duration | Filter `sm2.record_result` spans | > 50ms (algorithm is O(1)) |
| Session plan compute duration | Filter `session.compute_plan` spans | > 200ms |
| DB query latency | Filter `db.statement` spans within SM-2 spans | > 50ms |

### Infrastructure metrics (from Docker)

```bash
# Check container resource usage
docker stats --no-stream

# Example output:
# CONTAINER  CPU%  MEM USAGE/LIMIT  NET I/O
# app        0.1%  128MiB / 2GiB   1.2MB / 800KB
# db         0.2%  64MiB / 1GiB    200KB / 1MB
# redis      0.0%  8MiB / 256MiB   10KB / 8KB
```

Watch for:
- `app` memory creep above 512 MiB (Puma thread leak indicator)
- `db` CPU spike during SM-2 queue computation (missing index)
- `redis` memory exceeding configured `maxmemory` (if set)

### Log-based error detection

```bash
# Tail production logs for 5xx errors
docker compose -f docker-compose.prod.yml logs -f app | grep '"status":5'

# Find SM-2 errors in structured logs
docker compose -f docker-compose.prod.yml logs app | grep '"event":"sm2.' | jq .
```

---

## SM-2 Correctness Monitoring

The SM-2 algorithm is correctness-critical. Beyond latency, monitor for behavioral correctness indicators:

### Indicators of SM-2 malfunction

| Indicator | What it signals | How to detect |
|-----------|----------------|---------------|
| Ease factor below 1.3 for many exercises | Repeated incorrect answers, or EF floor not enforced | Query: `SELECT COUNT(*) FROM exercises WHERE ease_factor < 1.3` |
| next_review_date in the past by > 30 days | Carry-over accumulation; session cap not releasing deferred items | Query: `SELECT COUNT(*) FROM exercises WHERE next_review_date < NOW() - INTERVAL '30 days'` |
| interval_days = 1 for all exercises | SM-2 reset loop; schedule not advancing | Query: `SELECT AVG(interval_days) FROM exercises WHERE last_reviewed_at IS NOT NULL` |

Add these as weekly manual health checks (they take 10 seconds to run):

```bash
# Weekly SM-2 state sanity check
docker compose -f docker-compose.prod.yml exec db psql -U ${POSTGRES_USER} ${POSTGRES_DB} -c "
  SELECT
    COUNT(*) FILTER (WHERE ease_factor < 1.3) AS low_ease_factor_count,
    COUNT(*) FILTER (WHERE next_review_date < NOW() - INTERVAL '30 days') AS overdue_count,
    ROUND(AVG(interval_days), 1) AS avg_interval_days,
    ROUND(AVG(ease_factor), 2) AS avg_ease_factor
  FROM exercises
  WHERE last_reviewed_at IS NOT NULL;
"
```

---

## Runbook: Common Operational Procedures

### App container not starting

```bash
# Check logs
docker compose -f docker-compose.prod.yml logs app --tail 50

# Common causes:
# 1. Missing SECRET_KEY_BASE — check .env file
# 2. Database not ready — check db healthcheck: docker compose ps
# 3. Pending migrations — run: docker compose -f docker-compose.prod.yml run --rm app bundle exec rails db:migrate
```

### Database unreachable

```bash
# Check postgres container status
docker compose -f docker-compose.prod.yml ps db
docker compose -f docker-compose.prod.yml logs db --tail 20

# Restart if unhealthy
docker compose -f docker-compose.prod.yml restart db

# Verify data volume integrity
docker compose -f docker-compose.prod.yml exec db pg_isready -U ${POSTGRES_USER}
```

### Redis unreachable

```bash
# Check redis container status
docker compose -f docker-compose.prod.yml ps redis
docker compose -f docker-compose.prod.yml restart redis

# Session cache will be cold after restart — session plan will recompute on next open
# No data loss (Redis is cache only for session plans; Sidekiq queues persist in Redis AOF)
```

### Performance degradation (slow session dashboard)

```bash
# 1. Check Jaeger for slow spans: http://localhost:16686
#    Filter: service=ruby-learning-platform, operation=GET /session
#    Expand span tree to find slow child spans

# 2. Check DB for missing indexes
docker compose -f docker-compose.prod.yml exec db psql -U ${POSTGRES_USER} ${POSTGRES_DB} -c "
  EXPLAIN ANALYZE SELECT * FROM exercises WHERE next_review_date <= NOW() ORDER BY next_review_date LIMIT 12;
"
# Expect: Index Scan on exercises_next_review_date_idx

# 3. Check Redis cache hit
docker compose -f docker-compose.prod.yml exec redis redis-cli keys "session_plan:*"
```

### Rollback after failed deployment

See platform-architecture.md, Deployment Procedure section.

---

## Future Enhancements (Deferred)

These are explicitly out of scope for the foundational monitoring setup but documented for future reference:

| Enhancement | Trigger to add | Complexity |
|-------------|---------------|------------|
| Prometheus metrics scraping | Traffic exceeds 100 req/day | Medium |
| Grafana dashboard | Prometheus added | Low once Prometheus exists |
| Distributed trace sampling | Volume concern (never for 1 user) | Not applicable |
