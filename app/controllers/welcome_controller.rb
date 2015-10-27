class WelcomeController < ApplicationController
  skip_before_action :init
  def index
    if is_logged_in?
      redirect_to '/list'
    end
  end
end
