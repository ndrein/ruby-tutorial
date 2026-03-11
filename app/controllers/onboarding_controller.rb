class OnboardingController < ApplicationController
  VALID_EXPERIENCE_LEVELS = %w[expert beginner].freeze

  def experience
  end

  def update
    user_id = session[:user_id] || params[:user_id]
    user = User.find_by(id: user_id)

    unless VALID_EXPERIENCE_LEVELS.include?(params[:experience_level])
      render :experience, status: :unprocessable_entity and return
    end

    user&.update!(experience_level: params[:experience_level])
    redirect_to lesson_path(1)
  end
end
