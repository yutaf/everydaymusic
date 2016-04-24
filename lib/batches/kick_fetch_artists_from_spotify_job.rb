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

    # Update by #{bulk_count} queries each
    # bulk_count = 10
    bulk_count = 20
    i = 1
    # by #{m_unit} minutes
    m_unit = 5
    m = 0

    qs = []

    elements.each do |first_letter|
      elements.each do |second_letter|
        q = "#{first_letter}#{second_letter}"
        qs << q

        if i < bulk_count
          # Increment i
          i = i+1
        else
          FetchArtistsFromSpotifyJob.set(wait: m.minute).perform_later(qs)

          # Reset qs
          qs = []
          # Reset i
          i = 1
          # Update m
          m = m + m_unit
        end
      end
    end

    if qs.count > 0
      FetchArtistsFromSpotifyJob.set(wait: m.minute).perform_later(qs)
    end

  end
  self.execute
end