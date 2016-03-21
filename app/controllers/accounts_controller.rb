class AccountsController < ApplicationController
  before_action :set_user

  def update_artists
    @errors = []
    if params[:artist_names].nil?
      @errors.push(t 'account.errors.messages.blank_artist')
      set_registered_artist_names
      render :edit_artists
      return
    end

    not_registered_artist_names_with_downcase_key = {}
    params[:artist_names].each do |artist_name|
      not_registered_artist_names_with_downcase_key[artist_name.downcase] = artist_name
    end

    artist_names = Artist.where(name: params[:artist_names]).pluck(:name)

    artist_names.each do |artist_name|
      if not_registered_artist_names_with_downcase_key[artist_name.downcase].present?
        not_registered_artist_names_with_downcase_key.delete(artist_name.downcase)
      end
    end

    artists_models = []
    not_registered_artist_names_with_downcase_key.each do |k, not_registered_artist_name|
      artists_models << Artist.new(name: not_registered_artist_name)
    end

    begin
      ActiveRecord::Base.transaction do
        if artists_models.count > 0
          # Bulk insert
          Artist.import artists_models
        end

        # Fetch artists
        artists = Artist.where(name: params[:artist_names])

        # Insert into artists_users table
        @user.artists << artists

        redirect_to '/list'
        return
      end
    rescue => e
      logger.error e.inspect
      #TODO log to the file separated by date

      @errors.push(t 'account.errors.messages.db_error')
      set_registered_artist_names
      render :edit_artists
      return
    end
  end

  def edit_artists
    set_registered_artist_names
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
  def set_registered_artist_names
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
