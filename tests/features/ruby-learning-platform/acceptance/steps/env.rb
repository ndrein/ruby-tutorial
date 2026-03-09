# Cucumber environment configuration for Ruby Learning Platform acceptance tests.
#
# Loaded by Cucumber before any step definitions or feature files.
# Configures: test framework, support files, hooks, and test containers.

require "cucumber"
require "capybara"
require "capybara/cucumber"
require "factory_bot"
require "database_cleaner/active_record"

# Load support files
require_relative "support/world"
require_relative "support/docker_compose_helper"

# ---- Rails / App Loading ----
# Load the Rails application in test mode.
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../../../../../config/environment", __dir__)

# ---- Capybara Configuration ----
# Use rack_test driver for non-JS scenarios (faster).
# Use :selenium_headless for scenarios requiring JS (keyboard events, Turbo Streams).
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_headless
Capybara.app = Rails.application
Capybara.default_max_wait_time = 5

# ---- FactoryBot ----
World(FactoryBot::Syntax::Methods)
FactoryBot.find_definitions

# ---- Database Cleaner ----
# Truncation strategy for acceptance tests: each scenario gets a clean database.
# Slower than transaction strategy but required for Capybara system tests.
DatabaseCleaner.strategy = :truncation

# ---- Cucumber Hooks ----

Before do
  DatabaseCleaner.start
end

After do |scenario|
  DatabaseCleaner.clean

  # Capture screenshot on failure for debugging (requires JS driver)
  if scenario.failed? && Capybara.current_driver == Capybara.javascript_driver
    take_screenshot
  end
end

# ---- Walking Skeleton Hook ----
# Tag @wip scenarios run first in the implementation sequence.
# Tag @skip scenarios are excluded from the current run.
# To enable a scenario: remove @skip and replace with @wip until it passes,
# then remove @wip and enable the next @skip scenario.

Around("@skip") do |_scenario, _block|
  pending "Scenario not yet enabled. Remove @skip and add @wip to begin implementation."
end

# ---- Smoke Test Hook ----
# Smoke tests target the running application, not the test environment.
Around("@smoke") do |scenario, block|
  unless ENV["SMOKE_TEST_TARGET"]
    skip_this_scenario("Set SMOKE_TEST_TARGET env var to run smoke tests against a deployed instance.")
  end
  block.call
end

# ---- CI Validation Hook ----
# CI validation scenarios are documentation-only; they do not run as Cucumber tests.
Around("@ci_validation") do |_scenario, _block|
  pending "CI validation scenarios are documented expectations, not automated Cucumber tests."
end
