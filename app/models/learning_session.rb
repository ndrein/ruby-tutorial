class LearningSession < ApplicationRecord
  self.table_name = "sessions"

  belongs_to :user

  validates :started_at, presence: true
  validates :exercises_completed, numericality: { greater_than_or_equal_to: 0 }
  validates :session_date, presence: true
  validates :duration_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
