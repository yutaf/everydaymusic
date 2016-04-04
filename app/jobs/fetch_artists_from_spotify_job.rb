class FetchArtistsFromSpotifyJob < ActiveJob::Base
  queue_as :fetch_artists_from_spotify

  def perform
    # Set next schedule
    self.class.set(wait: 1.week).perform_later
    FetchArtistsFromSpotify.execute
  end
end