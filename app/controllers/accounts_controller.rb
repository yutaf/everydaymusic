class AccountsController < ApplicationController
  before_action :set_user

  def show
  end

  private
    def set_user
      @user = User.find_by(@user_id)
    end
end
