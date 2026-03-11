require 'date'
require_relative '../value_objects/sm2_input'
require_relative '../value_objects/sm2_result'

class SM2Engine
  EF_MIN = 1.3
  EF_MAX = 2.5

  INITIAL_INTERVAL    = 1
  INITIAL_REPETITIONS = 0

  PASSING_QUALITY_THRESHOLD = 3

  def self.call(input)
    interval, repetitions = next_schedule(input)
    new_ef = clamped_ease_factor(input)

    SM2Result.new(
      interval: interval,
      ease_factor: new_ef,
      repetitions: repetitions,
      next_review_date: Date.today + interval
    )
  end

  def self.next_schedule(input)
    if input.quality < PASSING_QUALITY_THRESHOLD
      [1, 0]
    else
      [next_interval(input), input.repetitions + 1]
    end
  end
  private_class_method :next_schedule

  def self.next_interval(input)
    case input.repetitions
    when 0 then 1
    when 1 then 6
    else (input.interval * input.ease_factor).round
    end
  end
  private_class_method :next_interval

  def self.clamped_ease_factor(input)
    delta = 0.1 - (5 - input.quality) * (0.08 + (5 - input.quality) * 0.02)
    raw_ef = input.ease_factor + delta
    raw_ef.clamp(EF_MIN, EF_MAX)
  end
  private_class_method :clamped_ease_factor
end
