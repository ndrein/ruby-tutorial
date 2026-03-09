# Observability Design — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Observability stack**: OpenTelemetry (vendor-agnostic) + Jaeger (local OTLP receiver)

---

## Overview

The observability stack is designed for a single-user personal tool running on-premise. The philosophy is:
- Traces for understanding SM-2 correctness-critical paths (where time goes, where failures occur).
- Structured JSON logs for runtime events and debugging.
- Health check endpoint for Docker Compose and operational monitoring.
- No expensive hosted observability platform — Jaeger runs as a local container.

Three pillars:

| Pillar | Tool | Purpose |
|--------|------|---------|
| Traces | OpenTelemetry SDK + Jaeger | Request flow, SM-2 path timing, latency profiling |
| Logs | lograge + semantic_logger | Structured JSON per-request and per-event |
| Metrics | OpenTelemetry metrics API | Key business and performance counters (future-ready) |

---

## Gem Dependencies

```ruby
# Gemfile

# OpenTelemetry SDK and Rails integration
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"         # OTLP/gRPC exporter to Jaeger
gem "opentelemetry-instrumentation-rails"  # Auto-instrumentation for Rails
gem "opentelemetry-instrumentation-active_record"  # DB query spans
gem "opentelemetry-instrumentation-action_controller"
gem "opentelemetry-instrumentation-action_view"
gem "opentelemetry-instrumentation-rack"

# Redis instrumentation (session cache + Sidekiq)
gem "opentelemetry-instrumentation-redis"

# Structured logging
gem "lograge"            # Converts Rails request log to single JSON line
gem "semantic_logger"    # Structured logger with JSON output (optional, see below)
```

---

## OpenTelemetry Initializer

```ruby
# config/initializers/opentelemetry.rb

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "ruby-learning-platform")
  c.service_version = ENV.fetch("APP_VERSION", "unknown")

  # OTLP exporter — sends traces to Jaeger (or any OTLP-compatible backend)
  # Endpoint is set via OTEL_EXPORTER_OTLP_ENDPOINT env var
  # Default: http://localhost:4317 (gRPC)
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new
    )
  )

  # Auto-instrumentation: instruments Rails, ActiveRecord, Rack, Redis
  c.use_all({
    "OpenTelemetry::Instrumentation::Rails" => {
      # Capture rendered template names in span attributes
      enable_recognize_route: true,
    },
    "OpenTelemetry::Instrumentation::ActiveRecord" => {
      # Capture DB query text (safe for personal tool; omit in multi-user)
      db_statement: :include,
    },
    "OpenTelemetry::Instrumentation::Redis" => {
      db_statement: :include,
    },
  })
end
```

Environment variables that control the exporter (set in docker-compose):

| Variable | Value | Effect |
|----------|-------|--------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://jaeger:4317` | Sends traces to Jaeger container |
| `OTEL_SERVICE_NAME` | `ruby-learning-platform` | Service name in Jaeger UI |
| `OTEL_TRACES_SAMPLER` | `always_on` | Sample every trace (1 user, no volume concern) |
| `OTEL_LOG_LEVEL` | `warn` | OTel SDK log verbosity |

---

## Manual Trace Instrumentation — SM-2 Correctness-Critical Paths

Auto-instrumentation covers Rails controller and DB spans. The correctness-critical domain paths require manual instrumentation to expose business-level timing and attributes.

### Tracer Module

```ruby
# app/domain/shared/tracer.rb

module Domain
  module Shared
    TRACER = OpenTelemetry.tracer_provider.tracer(
      "ruby-learning-platform.domain",
      ENV.fetch("APP_VERSION", "unknown")
    )
  end
end
```

### SM-2 ReviewScheduler Instrumentation

```ruby
# app/domain/sm2/review_scheduler.rb

class ReviewScheduler
  def record_result(exercise_id:, result:, answered_at:)
    Domain::Shared::TRACER.in_span("sm2.record_result") do |span|
      span.set_attribute("sm2.exercise_id", exercise_id.to_s)
      span.set_attribute("sm2.result", result.to_s)  # :correct / :incorrect / :skipped

      current_state = review_repository.find(exercise_id)

      span.set_attribute("sm2.current_interval_days", current_state.interval_days)
      span.set_attribute("sm2.current_ease_factor", current_state.ease_factor.to_f)

      new_state = Domain::Shared::TRACER.in_span("sm2.algorithm.compute") do |alg_span|
        alg_span.set_attribute("sm2.input.result", result.to_s)
        SM2Algorithm.call(
          current_interval: current_state.interval_days,
          ease_factor: current_state.ease_factor,
          result: result
        )
      end

      span.set_attribute("sm2.new_interval_days", new_state.interval_days)
      span.set_attribute("sm2.new_ease_factor", new_state.ease_factor.to_f)
      span.set_attribute("sm2.next_review_date", new_state.next_review_date.to_s)

      Domain::Shared::TRACER.in_span("sm2.persist_result") do |persist_span|
        persist_span.set_attribute("sm2.exercise_id", exercise_id.to_s)
        review_repository.update(exercise_id, new_state)
      end

      new_state
    rescue StandardError => e
      span.record_exception(e)
      span.status = OpenTelemetry::Trace::Status.error(e.message)
      raise
    end
  end
end
```

### SessionPlanner Instrumentation

```ruby
# app/domain/session/session_planner.rb

class SessionPlanner
  def compute_plan(user_id:, date:)
    Domain::Shared::TRACER.in_span("session.compute_plan") do |span|
      span.set_attribute("session.user_id", user_id.to_s)
      span.set_attribute("session.date", date.to_s)

      due_exercises = Domain::Shared::TRACER.in_span("session.fetch_review_queue") do |q_span|
        queue = review_queue.compute(date: date)
        q_span.set_attribute("session.review_count", queue.size)
        queue
      end

      next_lesson = Domain::Shared::TRACER.in_span("session.resolve_next_lesson") do |l_span|
        lesson = lesson_unlocker.next_available
        l_span.set_attribute("session.next_lesson_id", lesson&.id.to_s)
        lesson
      end

      plan = SessionPlan.new(exercises: due_exercises, next_lesson: next_lesson, date: date)

      Domain::Shared::TRACER.in_span("session.cache_plan") do |c_span|
        cache_key = "session_plan:#{user_id}:#{date}"
        c_span.set_attribute("session.cache_key", cache_key)
        session_repository.cache(cache_key, plan)
      end

      span.set_attribute("session.plan.exercise_count", due_exercises.size)
      span.set_attribute("session.plan.has_next_lesson", !next_lesson.nil?)

      plan
    end
  end
end
```

### LessonUnlocker Instrumentation (Prerequisite Unlock Transaction)

```ruby
# app/domain/curriculum/lesson_unlocker.rb

class LessonUnlocker
  def complete_lesson(lesson_id:)
    Domain::Shared::TRACER.in_span("curriculum.complete_lesson") do |span|
      span.set_attribute("curriculum.lesson_id", lesson_id.to_s)

      newly_unlocked = Domain::Shared::TRACER.in_span("curriculum.evaluate_unlock_conditions") do |u_span|
        # This runs inside a database transaction in the adapter
        unlocked = prerequisite_graph
          .successors(lesson_id)
          .select { |successor| prerequisites_met?(successor) }

        u_span.set_attribute("curriculum.newly_unlocked_count", unlocked.size)
        u_span.set_attribute("curriculum.newly_unlocked_ids", unlocked.map(&:to_s).join(","))
        unlocked
      end

      span.set_attribute("curriculum.unlock_count", newly_unlocked.size)
      newly_unlocked
    end
  end
end
```

---

## Structured JSON Logging

### lograge Configuration

```ruby
# config/initializers/lograge.rb

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Add custom fields to every request log line
  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:headers]["X-Request-Id"],
      # Correlate log line with active trace
      trace_id: OpenTelemetry::Trace.current_span.context.hex_trace_id,
      span_id: OpenTelemetry::Trace.current_span.context.hex_span_id,
      # Application-level context
      rails_env: Rails.env,
      host: event.payload[:host],
    }.compact
  end

  # Suppress asset pipeline logs in production
  config.lograge.ignore_actions = ["HealthController#show"]
end
```

### Example log output

```json
{
  "method": "POST",
  "path": "/exercises/42/results",
  "format": "html",
  "controller": "ExerciseResultsController",
  "action": "create",
  "status": 200,
  "duration": 48.3,
  "view": 12.1,
  "db": 18.7,
  "request_id": "9e4f8c2a-...",
  "trace_id": "7b2c8d1a9e4f3b6c...",
  "span_id": "1a2b3c4d...",
  "rails_env": "production"
}
```

### Domain event logging

For significant domain events (SM-2 state transitions, lesson completions), log with structured attributes:

```ruby
# app/domain/sm2/review_scheduler.rb

Rails.logger.info({
  event: "sm2.result_recorded",
  exercise_id: exercise_id,
  result: result,
  new_interval_days: new_state.interval_days,
  new_ease_factor: new_state.ease_factor.round(2),
  next_review_date: new_state.next_review_date.iso8601,
  trace_id: OpenTelemetry::Trace.current_span.context.hex_trace_id,
}.to_json)
```

### Rails logger JSON format

```ruby
# config/environments/production.rb
config.log_formatter = proc do |severity, _datetime, _progname, msg|
  entry = {
    level: severity,
    time: Time.current.iso8601(3),
    message: msg.is_a?(String) ? msg : msg.inspect,
  }
  "#{entry.to_json}\n"
end
```

---

## Health Check Endpoint

### Rails controller

```ruby
# app/controllers/health_controller.rb

class HealthController < ActionController::Base
  # Skip authentication / CSRF (health endpoint is public)
  skip_before_action :verify_authenticity_token, raise: false

  def show
    checks = {
      database: database_healthy?,
      redis: redis_healthy?,
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render json: {
      status: status == :ok ? "ok" : "degraded",
      checks: checks,
      timestamp: Time.current.iso8601,
      version: ENV.fetch("APP_VERSION", "unknown"),
    }, status: status
  end

  private

  def database_healthy?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def redis_healthy?
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379")).ping == "PONG"
  rescue StandardError
    false
  end
end
```

### Routes

```ruby
# config/routes.rb
get "/health", to: "health#show"
```

### Docker Compose healthcheck integration

The `app` service in `docker-compose.prod.yml` uses this endpoint:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

---

## Jaeger Setup

Jaeger `all-in-one` is the lightweight local OTLP receiver. It receives traces via OTLP/gRPC (port 4317) and exposes a UI (port 16686).

In production, Jaeger uses Badger storage (embedded key-value store) so traces persist across container restarts.

### Accessing Jaeger UI

From the host machine: `http://localhost:16686`

Key searches:
- Service: `ruby-learning-platform`
- Operation: `sm2.record_result` — see SM-2 computation timing
- Operation: `session.compute_plan` — see session plan timing
- Tag filter: `sm2.result=incorrect` — find all incorrect-answer traces

### Trace retention

Jaeger default retention in Badger: 72 hours. For a personal tool this is sufficient. Extend by setting `BADGER_TTL` environment variable if longer history is needed.

---

## Instrumentation Coverage Map

| Component | Instrumentation type | Spans / attributes |
|-----------|--------------------|--------------------|
| Rails controller | Auto (opentelemetry-instrumentation-rails) | Route, action, status, duration |
| ActiveRecord queries | Auto (opentelemetry-instrumentation-active_record) | SQL query, table, operation |
| Redis operations | Auto (opentelemetry-instrumentation-redis) | Command, key |
| SM2Algorithm compute | Manual | input result, interval, ease_factor, output |
| ReviewScheduler | Manual | exercise_id, result, new_interval, next_review_date |
| SessionPlanner | Manual | user_id, date, review_count, next_lesson_id |
| LessonUnlocker | Manual | lesson_id, newly_unlocked_count |
| Request logs | lograge JSON | method, path, status, duration, trace_id |
| Domain event logs | Structured JSON inline | event name, business attributes, trace_id |

---

## Performance Correlation

The architecture defines response time targets:

| View | Target | Trace operation to check |
|------|--------|--------------------------|
| Session dashboard | 500ms | `GET /session` controller span |
| SM-2 queue fetch | 200ms | `session.fetch_review_queue` span |
| Curriculum tree | 300ms | `GET /curriculum` controller span |
| Exercise feedback | 100ms | `POST /exercises/:id/results` controller span |

When a target is missed, the trace shows exactly which span (DB query, Redis fetch, domain computation) consumed the budget.
