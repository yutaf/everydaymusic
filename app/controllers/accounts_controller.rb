class AccountsController < ApplicationController
  before_action :set_user

  def update
    if @user.update(user_params)
      # Update redis user values
      @redis.mapped_hmset("user:#{@user_id}", user_params)
      # TODO notice が表示されない session problem??
      redirect_to account_path, notice: 'User was successfully updated.'
    else
      render 'edit'
    end
  end

  def show
  end

  def edit
  end

  private
    def set_user
      @user = User.find(@user_id)
    end

    def user_params
      params.require(:user).permit(:email)
    end
end
