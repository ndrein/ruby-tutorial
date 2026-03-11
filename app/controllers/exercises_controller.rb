class ExercisesController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id])
  end

  def submit
    exercise = Exercise.find(params[:id])
    answer = params[:answer].to_s.strip
    elapsed_seconds = params[:elapsed_seconds].to_i
    hard_flag = params[:hard_flag] == "true"

    answer_result = resolve_answer_result(exercise, answer)
    quality = ScoreCalculator.call(answer_result, elapsed_seconds, hard_flag)

    sm2_input = build_sm2_input(current_user_review(exercise), quality)
    sm2_result = SM2Engine.call(sm2_input)

    review = persist_review(exercise, sm2_result, answer_result, quality)

    render turbo_stream: turbo_stream.replace(
      "feedback",
      partial: "exercises/feedback",
      locals: { exercise: exercise, answer_result: answer_result, review: review }
    )
  end

  private

  def resolve_answer_result(exercise, answer)
    return :timeout if params[:answer_result] == "timeout"
    exercise.evaluate_answer(answer)
  end

  def current_user
    @current_user ||= User.first
  end

  def current_user_review(exercise)
    Review.find_by(user_id: current_user.id, exercise_id: exercise.id)
  end

  def build_sm2_input(existing_review, quality)
    if existing_review
      sm2_input_from_review(existing_review, quality)
    else
      sm2_input_for_new_card(quality)
    end
  end

  def sm2_input_from_review(review, quality)
    SM2Input.new(
      repetitions: review.repetitions,
      interval: review.sm2_interval,
      ease_factor: review.sm2_ease_factor.to_f,
      quality: quality
    )
  end

  def sm2_input_for_new_card(quality)
    SM2Input.new(
      repetitions: SM2Engine::INITIAL_REPETITIONS,
      interval: SM2Engine::INITIAL_INTERVAL,
      ease_factor: SM2Engine::EF_MAX,
      quality: quality
    )
  end

  def persist_review(exercise, sm2_result, answer_result, quality)
    user = current_user
    Review.transaction do
      Review.upsert(
        {
          user_id: user.id,
          exercise_id: exercise.id,
          sm2_interval: sm2_result.interval,
          sm2_ease_factor: sm2_result.ease_factor.round(2),
          repetitions: sm2_result.repetitions,
          next_review_date: sm2_result.next_review_date,
          answer_result: answer_result.to_s,
          quality_score: quality,
          reviewed_at: Time.current
        },
        unique_by: [ :user_id, :exercise_id ]
      )
    end
    Review.find_by!(user_id: user.id, exercise_id: exercise.id)
  end
end
