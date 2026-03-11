class User < ApplicationRecord
  has_secure_password

  has_many :reviews, dependent: :destroy
  has_many :learning_sessions, dependent: :destroy
  has_many :daily_queues, dependent: :destroy

  attribute :experience_level, :string, default: "expert"
  attribute :timezone, :string, default: "UTC"
  attribute :email_delivery_hour, :integer, default: 8
  attribute :streak_count, :integer, default: 0

  validates :email, presence: true, uniqueness: { message: "is already registered" }, length: { maximum: 255 }
  validates :experience_level, presence: true, inclusion: { in: %w[expert beginner] }
  validates :streak_count, numericality: { greater_than_or_equal_to: 0 }
  validates :email_delivery_hour, numericality: { in: 0..23 }
  validates :timezone, presence: true
end
