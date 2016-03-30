class FetchArtistsFromSpotifyJob < ActiveJob::Base
  queue_as :fetch_artists_from_spotify

  def perform(*args)
    require 'sidekiq/api'

    # clear scheduled fetch_artists_from_spotify ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'fetch_artists_from_spotify' }
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
    
    require "net/http"

    # Begin transaction
    begin
      ActiveRecord::Base.transaction do
        elements = [*('a'..'z'), *('0'..'9')]
        elements.each do |first_letter|
          elements.each do |second_letter|
            q = "#{first_letter}#{second_letter}"

            url = "https://api.spotify.com/v1/search?q=#{q}&type=artist&limit=5"
            # url = "https://api.spotify.com/v1/search?q=#{q}&type=artist&limit=50"
            uri = URI.parse(url)
            https = Net::HTTP.new(uri.host,uri.port)
            #httpsだとこれ必要
            https.use_ssl = true

            res = https.start {
              https.get(uri.request_uri)
            }

            if res.code == '200'
              result = JSON.parse(res.body)
              Rails.logger.info result.class
              Rails.logger.info result.inspect
              Rails.logger.info result[:artists]
              Rails.logger.info result['artists']

              # resultを使ってなんやかんや処理をする
            else
              puts "OMG!! #{res.code} #{res.message}"
            end

            return
          end
        end
      end
    rescue => e
      Rails.logger.info e.inspect
      logger.error e.message
    end
  end
end