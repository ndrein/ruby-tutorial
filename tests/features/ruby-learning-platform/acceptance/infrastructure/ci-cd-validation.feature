# CI/CD Pipeline Validation
#
# Documents the observable outcomes the CI pipeline must produce.
# These are expressed as BDD scenarios for clarity, but are validated by
# inspecting pipeline run results and artifacts in GitHub Actions — not
# by running a Cucumber test against the pipeline itself.
#
# Reference: docs/feature/ruby-learning-platform/devops/ci-cd-pipeline.md

Feature: CI/CD pipeline enforces quality gates on every commit
  As a developer maintaining the Ruby Learning Platform
  I want the CI pipeline to catch regressions before they reach production
  So that the main branch remains releasable at all times

  # ---- Lint and Security (ci.yml job: lint-audit) ----

  @ci_validation
  Scenario: Every commit triggers the lint and security audit job
    Given a commit is pushed to main or a pull request targets main
    When the CI pipeline runs
    Then the "Lint and Security Audit" job runs
    And RuboCop style enforcement completes without violations
    And Brakeman security analysis finds no warnings
    And bundler-audit finds no known CVE vulnerabilities in the dependency tree

  @ci_validation
  Scenario: RuboCop violations fail the pipeline before tests run
    Given a commit contains a RuboCop style violation
    When the CI pipeline runs the lint job
    Then the lint job fails
    And the unit test and integration test jobs do not run

  # ---- Unit Tests (ci.yml job: unit-tests) ----

  @ci_validation
  Scenario: Domain unit tests run without a database on every commit
    Given a commit is pushed
    When the CI pipeline runs the unit test job
    Then RSpec executes only the tests in spec/domain/
    And no PostgreSQL or Redis service is started for this job
    And the job completes in under 5 minutes

  # ---- Integration Tests (ci.yml job: integration-tests) ----

  @ci_validation
  Scenario: Integration tests run with real PostgreSQL and Redis services
    Given the lint and unit test jobs have both passed
    When the CI pipeline runs the integration test job
    Then PostgreSQL 17 and Redis 7 services are started
    And the database schema is loaded from the schema file
    And the curriculum seed data is loaded from the YAML fixtures
    And the full RSpec suite runs against the real services

  @ci_validation
  Scenario: SimpleCov coverage gate enforces 90% minimum on integration tests
    Given the integration test job runs with coverage enabled
    When the full test suite completes
    Then the coverage report is generated
    And if total line coverage is below 90% the integration job fails
    And the coverage report is uploaded as a build artifact

  # ---- Mutation Tests (ci.yml job: mutation-tests) ----

  @ci_validation
  Scenario: Mutation tests run only on push to main, not on pull requests
    Given a pull request is open targeting main
    When the CI pipeline runs
    Then the mutation test job does not run
    And only lint, unit, and integration jobs are required for PR merge

  @ci_validation
  Scenario: Mutation tests on main are scoped to files changed in the commit
    Given a commit to main modifies files in app/domain/sm2/
    When the CI pipeline runs the mutation test job
    Then mutation testing runs only against the modified domain files
    And if the mutation kill rate for those files is below 80% the job fails
    And if no domain files were changed the mutation test job reports "skipped" and passes

  @ci_validation
  Scenario: Mutation tests on main with no domain changes complete successfully without testing
    Given a commit to main modifies only view templates and no domain files
    When the CI pipeline runs the mutation test job
    Then the job outputs "No domain/adapter file changes detected. Mutation tests skipped."
    And the job exits successfully

  # ---- Deployment (deploy.yml) ----

  @ci_validation
  Scenario: Deployment workflow requires manual trigger and a passing CI run
    Given the operator wants to deploy to production
    When the deploy workflow is triggered manually via workflow_dispatch
    Then the deployment only proceeds if the target commit has a passing CI run
    And the "production" GitHub environment protection rules are checked before proceeding

  @ci_validation
  Scenario: Deployment executes a pre-deployment database backup before recreating the container
    Given the deploy workflow has been triggered
    When the deployment steps execute
    Then a database backup is created before the application container is recreated
    And the backup file is stored on the host with a timestamp

  @ci_validation
  Scenario: Deployment health check triggers automatic rollback on failure
    Given a new version has been deployed
    When the post-deployment health check fails after 5 attempts over 50 seconds
    Then the deployment is marked as failed
    And the previous image tagged "rollback" is restored
    And the application container is restarted with the rollback image

  # ---- Branch Protection ----

  @ci_validation
  Scenario: Pull requests to main cannot be merged until all required checks pass
    Given a pull request is open targeting main
    Then the "Lint and Security Audit" check must pass before merge is allowed
    And the "Unit Tests (Domain)" check must pass before merge is allowed
    And the "Integration Tests" check must pass before merge is allowed
    And the "Mutation Tests" check is not required for pull request merge

  # ---- Pipeline Performance ----

  @ci_validation
  Scenario: Full pipeline on main completes within the performance target
    Given a commit is pushed to main
    When all CI jobs complete
    Then the lint and unit jobs (running in parallel) finish within 5 minutes
    And the integration test job finishes within 15 minutes after the parallel jobs
    And the mutation test job finishes within 15 minutes after integration
    And the total elapsed pipeline time is under 40 minutes
