class InsertIntoDeliveries
  def self.execute
    require 'google/api_client'
    require 'rspotify'

    # TODO try catch

    client = Google::APIClient.new(
        key: 'AIzaSyB8WbAOkKfPqY5peLhcdsXrPLeUzcskoMU', #TODO
        authorization: nil,
        application_name: 'everydaymusic',
        application_version: '1.0.0'
    )
    youtube = client.discovered_api('youtube', 'v3')
    random_words_for_search = %w(live)

    artists_to_import = []

    # Begin transaction
    begin
      ActiveRecord::Base.transaction do
        artist_records = Artist.pluck(:name)
        users = User.includes(:artists).all.select(:id)
        users.each do |user|

          if user.artists.count == 0
            next
          end

          # Define artist being used as a search keyword
          artist = user.artists.to_a.sample(1)[0][:name]

          # search related artists at a rate of 1 / 5
          if 1 == rand(5)
            spotify_artists = RSpotify::Artist.search(artist)
            if spotify_artists.instance_of?(Array) && spotify_artists.count > 0
              spotify_related_artists = spotify_artists.first.related_artists
              if spotify_related_artists.instance_of?(Array) && spotify_related_artists.count > 0
                # Sort array randomly
                spotify_related_artists.shuffle!

                spotify_related_artists.each do |a|
                  # check duplication of artists
                  if artist_records.include? a.name
                    next
                  end
                  # Update artist
                  artist = a.name
                  # Add artist to import array
                  artist_model = Artist.new(name: artist)
                  artists_to_import << artist_model
                  break
                end
              end
            end
          end

          search_query = artist
          # Add random words at a rate of 1 / 5
          if 1 == rand(5)
            search_query += ' ' + random_words_for_search.sample(1)[0]
          end

          begin
            search_response = client.execute!(
                :api_method => youtube.search.list,
                :parameters => {
                    # part: 'snippet',
                    part: 'id',
                    type: 'video',
                    q: search_query,
                    videoEmbeddable: 'true',
                    maxResults: 5
                }
            )

            if ! search_response.data.items.instance_of?(Array) && search_response.data.items == 0
              # TODO log
              next
            end
            #TODO existence check search_response.data.items.sample(1)[0].id.videoId
            # pp search_response.data.items.sample(1)[0].id.videoId
          rescue Google::APIClient::TransmissionError => e
            puts e.result.body
          end
        end

        if artists_to_import.count > 0
          # Bulk insert into artists
          # TODO validation
          Artist.import artists_to_import
        end
      end
    rescue => e
      #TODO log
      pp e
    end
  end

  InsertIntoDeliveries.execute
end