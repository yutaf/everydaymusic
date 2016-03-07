class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  before_action :set_facebook_app_id
  def index
    if is_logged_in?
      redirect_to '/list'
      return
    end

    @user = User.new
    @user.build_password
  end

  def create_user
    @user = User.new(user_params)
    @user.build_password(password_params)

    if @user.save
      #TODO sign up
      # @user.password << @password
      # @user.save
    else
      # Remove "is invalid" message by validates_associated
      @user.errors.delete :password

      @error_messages = @user.errors.full_messages.concat(@user.password.errors.full_messages)
      render 'index'
    end
  end

  private
  def set_facebook_app_id
    @facebook_app_id = ENV['FACEBOOK_APP_ID']
  end
  def user_params
    params.require(:user).permit(:email)
  end
  def password_params
    params.require(:password).permit(:password, :password_confirmation)
  end
end
