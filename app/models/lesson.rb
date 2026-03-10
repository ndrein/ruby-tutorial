class Lesson < ApplicationRecord
  belongs_to :course_module, foreign_key: :module_id, class_name: "CourseModule"

  has_many :exercises

  validates :title, presence: true, length: { maximum: 255 }
  validates :position_in_module, numericality: { in: 1..5 }
  validates :content_body, presence: true
  validates :python_equivalent, presence: true
  validates :java_equivalent, presence: true
  validates :estimated_minutes, numericality: { in: 1..5 }
  validates :prerequisite_ids, presence: false
end
