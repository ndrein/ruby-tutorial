class SessionsController < ApplicationController
  def new
    @user = current_user
    daily_queue = QueueBuilder.build(user_id: @user.id, date: Date.current)
    @exercise_ids = daily_queue.exercise_ids
    @exercises = Exercise.includes(:lesson).where(id: @exercise_ids).index_by(&:id)
    @queue_exercises = @exercise_ids.filter_map { |id| @exercises[id] }
    @streak_count = @user.streak_count
  end

  def create
    @learning_session = SessionTracker.start(current_user)
    redirect_to root_path
  end

  def summary
    @learning_session = LearningSession.find(params[:id])
  end

  private

  def current_user
    @current_user ||= User.first
  end
end
