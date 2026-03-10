class CourseModule < ApplicationRecord
  self.table_name = "modules"

  has_many :lessons, foreign_key: :module_id

  validates :title, presence: true, length: { maximum: 255 }
  validates :position, numericality: { in: 1..5 }, uniqueness: true
end
