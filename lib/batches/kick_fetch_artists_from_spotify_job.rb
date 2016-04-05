class KickFetchArtistsFromSpotifyJob
  def self.execute
    require 'sidekiq/api'

    # clear scheduled fetch_artists_from_spotify ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'fetch_artists_from_spotify' }
    jobs.each(&:delete)
    # Set job
    FetchArtistsFromSpotifyJob.set(wait: 1.week).perform_later
  end
  self.execute
end