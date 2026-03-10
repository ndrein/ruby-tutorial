class Exercise < ApplicationRecord
  belongs_to :lesson

  has_many :reviews

  EXERCISE_TYPES = %w[fill_in_blank multiple_choice spot_the_bug translation].freeze

  validates :exercise_type, presence: true, inclusion: { in: EXERCISE_TYPES }
  validates :prompt, presence: true
  validates :correct_answer, presence: true, length: { maximum: 500 }
  validates :explanation, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 1 }

  def evaluate_answer(submitted)
    return :correct if submitted == correct_answer
    return :correct if accepted_synonyms.include?(submitted)
    :incorrect
  end
end
