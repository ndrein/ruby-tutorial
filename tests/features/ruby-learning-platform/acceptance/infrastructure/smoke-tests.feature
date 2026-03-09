# Infrastructure Smoke Tests
#
# Validates that the platform is running correctly after deployment.
# These tests are intentionally shallow — they verify the system is up,
# not that business logic is correct (that is covered by acceptance tests).
#
# Run against: deployed environment (Docker Compose production stack)
# Framework: Cucumber + Net::HTTP (no app-level dependencies)

Feature: Platform is running and all services are healthy after deployment
  As an operator deploying the Ruby Learning Platform
  I want a post-deployment smoke test suite
  So that I know the platform is serving requests and all services are connected

  # ---- Application Health ----

  @smoke
  Scenario: Health endpoint returns a healthy status
    When a request is made to the health endpoint
    Then the response indicates the application is healthy
    And the response arrives within 2 seconds

  @smoke
  Scenario: Application home page is reachable
    When a request is made to the application home URL
    Then the response indicates the page loaded successfully
    And the response contains content expected on the welcome screen

  # ---- Database Connectivity ----

  @smoke
  Scenario: Application can read from the database
    When a request is made to the health endpoint with database check
    Then the response confirms the database connection is active
    And the response confirms the database schema is present

  @smoke
  Scenario: Curriculum data is loaded and accessible
    When a request is made to the curriculum status endpoint
    Then the response shows all 25 lessons are present in the curriculum
    And the prerequisite graph is loaded and acyclic

  # ---- Redis Connectivity ----

  @smoke
  Scenario: Application can connect to Redis
    When a request is made to the health endpoint with cache check
    Then the response confirms the Redis connection is active
    And the response confirms Redis responds within the latency threshold

  # ---- Session Functionality ----

  @smoke
  Scenario: Platform serves the onboarding screen for a fresh session
    Given no prior session state exists
    When a request is made to the platform entry point
    Then the onboarding screen content is present in the response

  # ---- Observability ----

  @smoke
  Scenario: Jaeger UI is reachable on the local host
    When a request is made to the Jaeger UI endpoint
    Then the response indicates the Jaeger service is running
    And the trace query interface is accessible

  # ---- Static Assets ----

  @smoke
  Scenario: Application stylesheet is served correctly
    When a request is made for the primary application stylesheet
    Then the stylesheet is returned with the correct content type
    And the response arrives within 1 second

  @smoke
  Scenario: Application JavaScript is served correctly
    When a request is made for the primary application JavaScript bundle
    Then the JavaScript file is returned with the correct content type
    And the response arrives within 1 second
