class FetchArtistsFromSpotifyJob < ActiveJob::Base
  queue_as :fetch_artists_from_spotify

  def perform(q)
    # Set next schedule
    self.class.set(wait: 1.month).perform_later(q)

    Spotify.fetch(q)
  end
end