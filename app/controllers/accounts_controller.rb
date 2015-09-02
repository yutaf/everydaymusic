class AccountsController < ApplicationController
  def show
    @user = User.find_by(@user_id)
    render json: @user
  end

  private
    def set_user
      @user = User.find_by(@user_id)
    end
end
