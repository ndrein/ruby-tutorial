# Use Whenever gem to manage cron jobs.
# Run `bundle exec whenever --update-crontab` to apply.

every :day, at: "2:00 am" do
  runner "QueueBuilderJob.perform_later"
  runner "User.where(email_opted_in: true).find_each { |u| EmailDispatchJob.perform_later(u.id) }"
end
