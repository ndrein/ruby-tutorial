class SessionsController < ApplicationController
  def new
    # Render form to start a new session
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
