class DeliveryJob < ActiveJob::Base
  queue_as :delivery

  def perform

    require 'sidekiq/api'

    # clear scheduled delivery ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'delivery' }
    jobs.each(&:delete)
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
    deliveries_model_values = []

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
        active_users = User.where("is_active=? AND email != ''", true).select(:id, :delivery_time)
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

        users = User.select(:id, :delivery_time, :email, :locale, :timezone).includes(:artists).where(is_active: true).find(target_user_ids)
        users_by_user_id = {}
        titles_by_user_id = {}
        artist_names_by_user_id = {}
        selected_artist_names = []
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
                    part: 'snippet',
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
            title = ''
            search_response.data.items.shuffle!.each do |item|
              if ! delivered_video_ids_by_user_id[user.id].blank? && delivered_video_ids_by_user_id[user.id].include?(item.id.videoId)
                # Exclude already delivered videoId
                next
              end
              video_id = item.id.videoId
              title = item.snippet.title
            end

            # TODO video_id が決定されなかった場合の処理
            if video_id.length == 0
              next
            end

            # Add delivery model to inserting values
            date = delivery_dates_by_user_id[user.id]
            deliveries_model_values << {user_id: user.id, video_id: video_id, title: title, date: date, is_delivered: false}
            # push email by user_id
            users_by_user_id[user.id] = user
            titles_by_user_id[user.id] = title
            artist_names_by_user_id[user.id] = artist_name
            selected_artist_names.push(artist_name)

          rescue Google::APIClient::TransmissionError => e
            Rails.logger.info e.inspect
            logger.error e.result.body
          end
        end

        if artists_models.count > 0
          # Bulk insert
          Artist.import artists_models
        end

        if deliveries_model_values.count > 0
          # Add artist_id to deliveries
          artists = Artist.select(:id, :name).where('name IN (?)', selected_artist_names)
          artist_ids_with_name_key = artists.map {|artist| [artist.name, artist.id]}.to_h
          deliveries_models = []
          deliveries_model_values.each do |deliveries_model_value|
            artist_name_by_user_id = artist_names_by_user_id[deliveries_model_value[:user_id]]
            artist_id = artist_ids_with_name_key[artist_name_by_user_id]
            deliveries_models << Delivery.new(user_id: deliveries_model_value[:user_id], artist_id: artist_id, video_id: deliveries_model_value[:video_id], title: deliveries_model_value[:title], date: deliveries_model_value[:date], is_delivered: deliveries_model_value[:is_delivered])
          end

          # Bulk insert
          Delivery.import deliveries_models

          # delivery_ids_with_user_id_key
          not_delivered_deliveries = Delivery.select(:id, :user_id).where(is_delivered: false)
          delivery_ids_with_user_id_key = not_delivered_deliveries.map {|delivery| [delivery.user_id, delivery.id]}.to_h

          #
          # Queue jobs
          #
          redis = Redis.new(host: ENV['REDIS_HOST'])
          deliveries_models.each do |deliveries_model|
            # Insert key for unsubscribe
            old_unsubscribe_key = redis.hget("user:#{deliveries_model.user_id}", 'unsubscribe_key')
            new_unsubscribe_key = MyStringer.create_random_uniq_str
            redis.multi do |multi|
              multi.hset("user:#{deliveries_model.user_id}", 'unsubscribe_key', new_unsubscribe_key)
              multi.hset('unsubscribe_keys', new_unsubscribe_key, deliveries_model.user_id)
            end
            if old_unsubscribe_key.is_a?(String) && old_unsubscribe_key.length > 0
              redis.hdel('unsubscribe_keys', old_unsubscribe_key)
            end
            # Send mail
            user = users_by_user_id[deliveries_model.user_id]
            title = titles_by_user_id[deliveries_model.user_id]
            date = deliveries_model.date

            # Get local date
            timezone = user['timezone'].to_i
            timezone_abs = timezone.abs
            operator = '-'
            if timezone < 0
              operator = '+'
            end
            hour = "%02d"%[timezone_abs]
            utc_date = date.strftime("%F %T")
            date_local = Time.zone.parse("#{utc_date} #{operator}#{hour}00")

            delivery_id = delivery_ids_with_user_id_key[deliveries_model.user_id]

            DeliveryMailer.sendmail(user[:email], delivery_id, new_unsubscribe_key, user[:locale], title, date_local.to_i).deliver_later(wait_until: date)
            # Update deliveries.is_delivered
            UpdateIsDeliveredJob.set(wait_until: date).perform_later(delivery_id)
          end
        end

      end
    rescue => e
      Rails.logger.info e.inspect
      logger.error e.message
    end
  end
end
