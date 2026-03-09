# Docker Compose helper for acceptance test environment setup.
#
# Smoke tests (tagged @smoke) run against a deployed Docker Compose stack,
# not against the in-process test application. This helper provides utilities
# for that scenario.
#
# For regular acceptance tests (tagged @wip or no tag), this file is not used
# because the test environment uses GitHub Actions services (PostgreSQL, Redis)
# directly via DATABASE_URL and REDIS_URL environment variables.

require "net/http"
require "uri"
require "json"

module DockerComposeHelper
  # Base URL for the running Docker Compose stack under test.
  # Configured via SMOKE_TEST_TARGET environment variable.
  # Example: SMOKE_TEST_TARGET=http://localhost:3000
  def smoke_test_base_url
    ENV.fetch("SMOKE_TEST_TARGET", "http://localhost:3000")
  end

  # Make an HTTP GET request to the smoke test target.
  # Returns a Net::HTTPResponse.
  def smoke_get(path)
    uri = URI.parse("#{smoke_test_base_url}#{path}")
    Net::HTTP.get_response(uri)
  rescue Net::ConnectTimeout, Errno::ECONNREFUSED => e
    raise "Smoke test target is not reachable at #{smoke_test_base_url}: #{e.message}"
  end

  # Assert the response status indicates success (2xx).
  def assert_healthy_response(response, path)
    unless response.code.to_i.between?(200, 299)
      raise "Expected a healthy response from #{path} but got HTTP #{response.code}"
    end
  end

  # Parse the response body as JSON.
  def parse_json_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Expected JSON response body but could not parse: #{e.message}"
  end

  # Check if the smoke test target is running before the suite starts.
  # Called in a Before hook for @smoke tagged scenarios.
  def assert_smoke_target_reachable
    response = smoke_get("/health")
    assert_healthy_response(response, "/health")
  rescue => e
    raise "Smoke test prerequisites failed — target not reachable: #{e.message}"
  end

  # ---- Service Health Check Helpers ----

  # Check that the application health endpoint reports all services healthy.
  def application_health_status
    response = smoke_get("/health")
    parse_json_response(response)
  end

  # Check that the Jaeger UI is reachable at its expected local port.
  # Jaeger UI binds to 127.0.0.1:16686 per the production compose file.
  def jaeger_health_status
    uri = URI.parse("http://localhost:16686/")
    Net::HTTP.get_response(uri)
  rescue Net::ConnectTimeout, Errno::ECONNREFUSED
    nil
  end
end

World(DockerComposeHelper)

# ---- Before Hook for Smoke Tests ----
Before("@smoke") do
  assert_smoke_target_reachable
end
