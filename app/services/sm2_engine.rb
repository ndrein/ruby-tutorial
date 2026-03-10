require 'date'
require_relative '../value_objects/sm2_input'
require_relative '../value_objects/sm2_result'

class SM2Engine
  EF_MIN = 1.3
  EF_MAX = 2.5

  def self.call(input)
    if input.quality < 3
      new_interval = 1
      new_repetitions = 0
    else
      new_interval = case input.repetitions
                     when 0 then 1
                     when 1 then 6
                     else (input.interval * input.ease_factor).round
                     end
      new_repetitions = input.repetitions + 1
    end

    raw_ef = input.ease_factor + (0.1 - (5 - input.quality) * (0.08 + (5 - input.quality) * 0.02))
    new_ef = [[raw_ef, EF_MAX].min, EF_MIN].max

    SM2Result.new(
      interval: new_interval,
      ease_factor: new_ef,
      repetitions: new_repetitions,
      next_review_date: Date.today + new_interval
    )
  end
end
