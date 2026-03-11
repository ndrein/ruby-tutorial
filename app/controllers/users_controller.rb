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
      @duplicate_email = duplicate_email_error?(@user)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def duplicate_email_error?(user)
    user.errors[:email].any? { |msg| msg.include?("taken") || msg.include?("already") }
  end
end
