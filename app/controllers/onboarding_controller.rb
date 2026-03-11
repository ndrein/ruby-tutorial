class OnboardingController < ApplicationController
  def experience
  end

  def update
    user_id = session[:user_id] || params[:user_id]
    user = User.find_by(id: user_id)

    if user && params[:experience_level] == "expert"
      user.update!(experience_level: "expert")
    end

    redirect_to lesson_path(1)
  end
end
