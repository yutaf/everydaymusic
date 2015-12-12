class DeliveryJob < ActiveJob::Base
  queue_as :delivery

  def perform
    # Set next schedule
    self.class.set(wait: 1.hour).perform_later

    # log setting
    file = File.open('log/app.log', File::WRONLY | File::APPEND | File::CREAT)
    logger = Logger.new(file, 'daily')
    logger.formatter = proc do |severity, datetime, progname, msg|
      caller_location = caller_locations(5,1)[0]
      "#{datetime} #{severity} #{caller_location} : #{msg}\n"
    end

    require 'google/api_client'
    require 'rspotify'

    client = Google::APIClient.new(
        key: ENV['GOOGLE_API_KEY'],
        authorization: nil,
        application_name: 'everydaymusic',
        application_version: '1.0.0'
    )
    youtube = client.discovered_api('youtube', 'v3')
    search_random_words = %w(live)

    # insert values
    artists_models = []
    deliveries_models = []

    # Begin transaction
    begin
      ActiveRecord::Base.transaction do
        artist_names = Artist.pluck(:name)
        # fetch delivered video_ids by user_id (from only active user)
        delivered_video_ids_by_user_id = {}
        deliveries = Delivery.joins(:user).where(users: {is_active: true}).select(:user_id, :video_id)

        if deliveries.to_a.count > 0
          deliveries.each do |delivery|
            unless delivered_video_ids_by_user_id.key?(delivery.user_id)
              # initialize array
              delivered_video_ids_by_user_id[delivery.user_id] = []
            end
            delivered_video_ids_by_user_id[delivery.user_id].push delivery.video_id
          end
        end

        # Fetch users who don't have a record which has deliveries.is_delivered = 0 and whose delivery_time comes within 3 hours
        active_users = User.where('is_active=?', true).select(:id, :delivery_time)
        if active_users.to_a.count == 0
          logger.info 'No active user exists'
          return
        end
        user_ids = []
        delivery_dates_by_user_id = {}
        dt_now_plus_3_hours = DateTime.now + 3.hours
        active_users.each do |active_user|
          dt_delivery_date = DateTime.now.change({ hour: active_user.delivery_time.hour, min: active_user.delivery_time.min, sec: active_user.delivery_time.sec })
          if dt_delivery_date.utc < DateTime.now.utc
            dt_delivery_date = dt_delivery_date + 1.day
          end
          if dt_delivery_date.utc > dt_now_plus_3_hours.utc
            next
          end
          user_ids.push(active_user.id)
          delivery_dates_by_user_id[active_user.id] = dt_delivery_date.strftime("%F %T")
        end
        if user_ids.count == 0
          logger.info 'No user needs to be cued'
          return
        end

        delivery_scheduled_user_ids = Delivery.joins(:user).where('deliveries.is_delivered=? AND users.is_active=?', false, true).group(:user_id).pluck(:user_id)

        target_user_ids = user_ids - delivery_scheduled_user_ids
        if target_user_ids.count == 0
          logger.info 'No user needs to be cued'
          return
        end

        users = User.select(:id, :delivery_time, :email).includes(:artists).where(is_active: true).find(target_user_ids)
        users.each do |user|
          if user.artists.size == 0
            next
          end

          # Define artist_name being used as a search keyword
          artist_name = user.artists.to_a.sample(1)[0][:name]

          #TODO It is time consuming to fetch related artists by api requests everytime, so fetch all related artists before this and save them in a table.
          # search related artists at a rate of 1 / 5
          if 1 == rand(5)
            spotify_artists = RSpotify::Artist.search(artist_name)
            if spotify_artists.instance_of?(Array) && spotify_artists.count > 0
              spotify_related_artists = spotify_artists.first.related_artists
              if spotify_related_artists.instance_of?(Array) && spotify_related_artists.count > 0
                # Sort array randomly
                spotify_related_artists.shuffle!

                spotify_related_artists.each do |a|
                  # check duplication of artists
                  if artist_names.include? a.name
                    next
                  end
                  # Update artist_name
                  artist_name = a.name
                  # Add new artist to inserting values
                  artists_models << Artist.new(name: artist_name)
                  break
                end
              end
            end
          end

          search_query = artist_name
          # Add random words at a rate of 1 / 5
          if 1 == rand(5)
            search_query += ' ' + search_random_words.sample(1)[0]
          end

          begin
            search_response = client.execute!(
                :api_method => youtube.search.list,
                :parameters => {
                    part: 'id',
                    type: 'video',
                    q: search_query,
                    videoEmbeddable: 'true',
                    # relatedToVideoId: '1234beatyourheart', # for error debug
                    maxResults: 5
                }
            )
            if ! search_response.data.items.instance_of?(Array) || search_response.data.items.size == 0
              message = "No item returned from youtube search. The search query is: '#{search_query}'"
              logger.error message
              next
            end

            video_id = ''
            search_response.data.items.shuffle!.each do |item|
              if delivered_video_ids_by_user_id[user.id].present? && delivered_video_ids_by_user_id[user.id].include?(item.id.videoId)
                # Exclude already delivered videoId
                next
              end
              video_id = item.id.videoId
            end

            # TODO video_id が決定されなかった場合の処理
            if video_id.length == 0
              next
            end

            # Add delivery model to inserting values
            date = delivery_dates_by_user_id[user.id]
            deliveries_models << Delivery.new(user_id: user.id, video_id: video_id, date: date, is_delivered: false)
          rescue Google::APIClient::TransmissionError => e
            logger.error e.result.body
          end
        end

        if deliveries_models.count > 0
          # Bulk insert
          Delivery.import deliveries_models

          #
          # Queue jobs
          #

          # Update deliveries.is_delivered
          deliveries_models.each do |deliveries_model|
            delivery_id = Delivery.where(user_id: deliveries_model.user_id, is_delivered: false).pluck(:id)[0]
            UpdateIsDeliveredJob.set(wait_until: deliveries_model.date).perform_later(delivery_id)
          end
        end

        if artists_models.count > 0
          # Bulk insert
          Artist.import artists_models
        end
      end
    rescue => e
      logger.error e.message
    end
  end
end
