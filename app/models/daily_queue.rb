class DailyQueue < ApplicationRecord
  belongs_to :user

  validates :queue_date, presence: true
  validates :exercise_ids, presence: false
end
