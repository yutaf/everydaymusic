class KickFetchArtistsFromSpotifyJob
  def self.execute
    require 'sidekiq/api'

    # clear scheduled fetch_artists_from_spotify ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'fetch_artists_from_spotify' }
    jobs.each(&:delete)
    # Set job
    elements = [*('a'..'z'), *('0'..'9')]
    # elements = %w(a b 1) # Debug

    # Update by 5 queries each
    i = 1
    # h = 0
    # s = 0
    m = 0

    elements.each do |first_letter|
      elements.each do |second_letter|
        q = "#{first_letter}#{second_letter}"

        # Rails.logger.info "q: #{q}, will be executed: #{h}hour later"
        # FetchArtistsFromSpotifyJob.set(wait: h.hour).perform_later(q)
        # FetchArtistsFromSpotifyJob.set(wait: s.second).perform_later(q)
        FetchArtistsFromSpotifyJob.set(wait: m.minute).perform_later(q)

        if i < 5
          # Increment i
          i = i+1
        else
          # Reset
          i = 1
          # Update h
          # h = h+2
          # s = s+30
          m = m+5
        end
      end
    end
  end
  self.execute
end