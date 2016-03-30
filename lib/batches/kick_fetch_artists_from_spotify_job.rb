class KickFetchArtistsFromSpotifyJob
  def self.execute
    FetchArtistsFromSpotifyJob.perform_later
  end
  KickFetchArtistsFromSpotifyJob.execute
end