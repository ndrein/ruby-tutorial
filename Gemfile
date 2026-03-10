source "https://rubygems.org"
ruby "3.2.3"

gem "rails", "~> 8.1.0"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "propshaft"
gem "solid_queue"
gem "whenever", "~> 1.0", require: false
gem "postmark-rails", "~> 0.22"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "debug", platforms: %i[ mri windows ]
end

group :test do
  gem "capybara", "~> 3.39"
  gem "selenium-webdriver"
  gem "mutant", "~> 0.11"
  gem "mutant-rspec", "~> 0.11"
end
