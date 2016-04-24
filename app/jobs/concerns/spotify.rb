class Spotify
  def self.fetch(q)
    # log setting
    file = File.open('log/spotify.log', File::WRONLY | File::APPEND | File::CREAT)
    logger = Logger.new(file, 'daily')
    logger.formatter = proc do |severity, datetime, progname, msg|
      caller_location = caller_locations(5,1)[0]
      "#{datetime} #{severity} #{caller_location} : #{msg}\n"
    end
    # Set log level
    Rails.logger.level = Logger::INFO

    begin
      spotify_artist_names = []
      if q.is_a? Array
        q.each do |query|
          url = "https://api.spotify.com/v1/search?q=#{query}&type=artist&limit=50"
          spotify_artist_names = get_artist_names(url, spotify_artist_names)
        end
      else
        query = q
        # query = "The%20Str"
        # query = "The%20Strasdfasdfasfewtawewatwatsadfsdagsasageratkdjgaljgfagjapgjijdaspgjfpsaf"
        # query = 'Muse'

        url = "https://api.spotify.com/v1/search?q=#{query}&type=artist&limit=50"

        #
        # Error Debug
        #

        # throw exception
        # url = "https://api.foo.bar.com/v1/search?q=#{query}&type=artist&limit=5"
        # 404 error
        # url = "https://api.spotify.com/v1/searchss?q=#{query}&type=artist&limit=5"
        # 401 error
        # url = "https://api.spotify.com/v1/nonexistence?q=#{query}&type=artist&limit=5"

        spotify_artist_names = get_artist_names(url)
      end

      if spotify_artist_names.count == 0
        return
      end

      dc_spotify_artist_names = spotify_artist_names.map{|item| item.downcase}

      artist_names = Artist.pluck(:name)
      dc_artist_names = artist_names.map{|item| item.downcase}

      dc_insert_artist_names = dc_spotify_artist_names - dc_artist_names
      if dc_insert_artist_names.count == 0
        return
      end

      # insert する Artist の小文字が分かったので、小文字化していない状態に戻した model 配列を作成
      artists_models = []
      spotify_artist_names.each do |spotify_artist_name|
        if ! dc_insert_artist_names.include?(spotify_artist_name.downcase)
          next
        end
        # Rails.logger.info spotify_artist_name
        artists_models << Artist.new(name: spotify_artist_name)
      end

      # Begin transaction
      ActiveRecord::Base.transaction do
        # bulk insert Artist
        Artist.import artists_models

        # raise 'Debug'
      end
    rescue => e
      Rails.logger.info e.inspect
      logger.error e.message
    ensure
      # Disconnect DB because of error below
      # #<ActiveRecord::ConnectionTimeoutError: could not obtain a database connection within 5.000 seconds (waited 5.058 seconds)>
      # http://h3poteto.hatenablog.com/entry/2015/03/31/013717
      ActiveRecord::Base.connection.close
    end
  end

  def self.get_artist_names(url, artist_names=[])
    Rails.logger.info url

    require "net/http"
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true

    res = https.start {
      https.get(uri.request_uri)
    }

    if res.code == '200'
      result = JSON.parse(res.body)
      if result['artists']['items'].count == 0
        return artist_names
      end

      # Sort by popularity
      result['artists']['items'].sort! { |a,b| b['popularity'] <=> a['popularity'] }
      # Remove artists which popularity is lower than 20
      result['artists']['items'].select! { |item| item['popularity'] >= 20 }
      # Remove duplicated values
      dc_artist_names = artist_names.map{|item| item.downcase}
      dc_result_artist_names = []

      result['artists']['items'].each do |item|
        if dc_artist_names.include?(item['name'].downcase)
          next
        end
        if dc_result_artist_names.include?(item['name'].downcase)
          next
        end

        # Rails.logger.info "#{item['name']}: #{item['popularity']}"
        artist_names << item['name']
        dc_result_artist_names << item['name'].downcase
      end

      if result['artists']['next'].blank?
        return artist_names
      end

      get_artist_names(result['artists']['next'], artist_names)
    else
      message = "OMG!! #{res.code} #{res.message} url: #{url}"
      raise(message)
    end
  end

  # Don't write self.execute because this class will be executed on class autoload when the rails process starts
end