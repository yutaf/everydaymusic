class AccountsController < ApplicationController
  before_action :set_user

  def edit_artists
    @registered_artist_names = Artist.pluck(:name)
    # debug for 0 artist
    # @registered_artist_names = Artist.where('id>99999').pluck(:name)

    @registered_artist_names_starting_with_the = []
    @registered_artist_names_starting_with_the_removed_the_lc = []
    @registered_artist_names.each do |registered_artist_name|
      registered_artist_name_lc = registered_artist_name.downcase
      res = registered_artist_name_lc.scan(/^the (.*)/)
      if res.count == 0
        next
      end
      @registered_artist_names_starting_with_the.push(registered_artist_name)
      @registered_artist_names_starting_with_the_removed_the_lc.push(res[0][0])
    end
  end

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
    @artist = nil
    if params[:artist_id].present?
      @artist = Artist.find_by(id: params[:artist_id])
    end
  end

  def set_user
    @user = User.find(@user_id)
  end

  def user_params
    params.require(:user).permit(:email, :is_active)
  end
end
