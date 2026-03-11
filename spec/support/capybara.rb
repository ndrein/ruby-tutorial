require "capybara/rspec"

# System tests without js: true use rack_test (no browser needed)
# System tests with js: true require a real browser driver
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_headless
  end
end
