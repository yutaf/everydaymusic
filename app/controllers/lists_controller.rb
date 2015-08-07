class ListsController < ApplicationController
  def show
    if ! is_logged_in?
      redirect_to '/login'
    end
  end
end
