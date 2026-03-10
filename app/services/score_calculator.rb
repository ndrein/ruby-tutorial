class ScoreCalculator
  def self.call(answer_result, elapsed_seconds, hard_flag)
    case answer_result
    when :timeout, :skipped
      0
    when :incorrect
      1
    when :correct
      return 3 if hard_flag

      if elapsed_seconds < 10
        5
      elsif elapsed_seconds < 25
        4
      elsif elapsed_seconds <= 30
        3
      else
        2
      end
    end
  end
end
