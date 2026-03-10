class Review < ApplicationRecord
  belongs_to :user
  belongs_to :exercise

  ANSWER_RESULTS = %w[correct incorrect skipped timeout].freeze

  validates :sm2_interval, numericality: { greater_than_or_equal_to: 1 }
  validates :sm2_ease_factor, numericality: {
    greater_than_or_equal_to: 1.30,
    less_than_or_equal_to: 2.50
  }
  validates :repetitions, numericality: { greater_than_or_equal_to: 0 }
  validates :next_review_date, presence: true
  validates :answer_result, presence: true, inclusion: { in: ANSWER_RESULTS }
  validates :quality_score, numericality: { in: 0..5 }
end
