class AccountsController < ApplicationController
  before_action :set_user

  def add_artist
    set_artist
    if @artist.blank?
      render json: {msg: 'invalid artist'}
      return
    end

    @user.artists << Artist.find(params[:artist_id])
    @user.save

    render json: {msg: 'Added artist'}
  end
  def delete_artist
    set_artist
    if @artist.blank?
      render json: {msg: 'invalid artist'}
      return
    end

    @user.artists.destroy(params[:artist_id])

    render json: {msg: 'Removed artist'}
  end

  def update
    if @user.update(user_params)
      # Update redis user values
      @redis.mapped_hmset("user:#{@user_id}", user_params)
      redirect_to account_path, notice: (t 'account.update_succeeded')
    else
      render 'edit'
    end
  end

  def show
    @user_status = (t 'account.status_inactive')
    if @user.is_active
      @user_status = (t 'account.status_active')
    end
  end

  def edit
    @is_active_checked = ! @user.is_active
  end

  private
  def set_artist
    if params[:artist_id].blank?
      @artist = nil
    end
    @artist = Artist.find_by(id: params[:artist_id])
  end

  def set_user
    @user = User.find(@user_id)
  end

  def user_params
    params.require(:user).permit(:email, :is_active)
  end
end
