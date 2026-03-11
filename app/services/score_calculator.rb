class ScoreCalculator
  FAST_THRESHOLD_SECONDS   = 10
  MEDIUM_THRESHOLD_SECONDS = 25
  SLOW_THRESHOLD_SECONDS   = 30

  SCORE_TIMEOUT   = 0
  SCORE_INCORRECT = 1
  SCORE_HARD      = 3
  SCORE_SLOW      = 2
  SCORE_MEDIUM    = 3
  SCORE_BRISK     = 4
  SCORE_FAST      = 5

  def self.call(answer_result, elapsed_seconds, hard_flag)
    case answer_result
    when :timeout, :skipped then SCORE_TIMEOUT
    when :incorrect         then SCORE_INCORRECT
    when :correct           then score_correct(elapsed_seconds, hard_flag)
    end
  end

  def self.score_correct(elapsed_seconds, hard_flag)
    return SCORE_HARD if hard_flag

    if elapsed_seconds < FAST_THRESHOLD_SECONDS
      SCORE_FAST
    elsif elapsed_seconds < MEDIUM_THRESHOLD_SECONDS
      SCORE_BRISK
    elsif elapsed_seconds <= SLOW_THRESHOLD_SECONDS
      SCORE_MEDIUM
    else
      SCORE_SLOW
    end
  end
  private_class_method :score_correct
end
