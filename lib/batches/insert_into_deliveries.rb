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
    random_words_for_search = %w(live)

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

        users = User.includes(:artists).all.select(:id)
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
            search_query += ' ' + random_words_for_search.sample(1)[0]
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


          rescue Google::APIClient::TransmissionError => e
            logger.error e.result.body
          end
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