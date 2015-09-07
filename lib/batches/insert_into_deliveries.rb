class InsertIntoDeliveries
  def self.execute
    require 'google/api_client'
    client = Google::APIClient.new(
        key: 'AIzaSyB8WbAOkKfPqY5peLhcdsXrPLeUzcskoMU', #TODO
        authorization: nil,
        application_name: 'everydaymusic',
        application_version: '1.0.0'
    )
    youtube = client.discovered_api('youtube', 'v3')

    users = User.includes(:artists).all.select(:id)
    users.each do |user|
      artist = user.artists.to_a.sample(1)[0][:name]
      query = "#{artist} glastonbury"
      search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => {
              part: 'id',
              type: 'video',
              q: query,
              maxResults: 1
          }
      )

      pp search_response
    end
  end

  InsertIntoDeliveries.execute
end