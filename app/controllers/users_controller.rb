class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(email: params.dig(:user, :email))
    @user.password = SecureRandom.hex(16)

    if @user.save
      session[:user_id] = @user.id
      redirect_to onboarding_experience_path
    else
      if @user.errors[:email].any? { |e| e.include?("taken") || e.include?("already") }
        @duplicate_email = true
      end
      render :new, status: :unprocessable_entity
    end
  end
end
