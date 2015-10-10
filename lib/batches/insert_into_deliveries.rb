class InsertIntoDeliveries
  def self.execute
    # log setting
    file = File.open('log/app.log', File::WRONLY | File::APPEND | File::CREAT)
    logger = Logger.new(file, 'daily')

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
    artists_inserts = []
    deliveries_inserts = []

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

        # Fetch users who don't have a record which is deliveries.is_delivered = 0
        user_ids = User.where(is_active: true).pluck(:id)
        if user_ids.count == 0
          logger.error 'No active user exists'
        end

        delivery_scheduled_user_ids = Delivery.joins(:user).where('deliveries.is_delivered=? AND users.is_active=?', false, true).group(:user_id).pluck(:user_id)
        target_user_ids = user_ids - delivery_scheduled_user_ids
        users = User.select(:id).includes(:artists).where(is_active: true).find(target_user_ids)
        users.each do |user|
          if user.artists.size == 0
            next
          end

          # Define artist_name being used as a search keyword
          artist_name = user.artists.to_a.sample(1)[0][:name]

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
                  artists_inserts << Artist.new(name: artist_name)
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
              if delivered_video_ids_by_user_id[user.id].include? item.id.videoId
                # Exclude already delivered videoId
                next
              end
              video_id = item.id.videoId
            end

            if video_id.length == 0
              next
            end

            #
            # Add video_id to inserting values
            #

            # Do not set value to deliveries.date here, it is to be set When the mail is being sent
            deliveries_inserts << Delivery.new(user_id: user.id, video_id: video_id, is_delivered: false)

          rescue Google::APIClient::TransmissionError => e
            logger.error e.result.body
          end
        end

        if deliveries_inserts.count > 0
          # Bulk insert into deliveries
          # TODO validation
          Delivery.import deliveries_inserts
        end

        if artists_inserts.count > 0
          # Bulk insert into artists
          # TODO validation
          Artist.import artists_inserts
        end
      end
    rescue => e
      logger.error e.message
    end
  end

  InsertIntoDeliveries.execute
end