class InsertIntoDeliveries
  def self.execute
    require 'google/api_client'
    client = Google::APIClient.new(
        key: 'AIzaSyB8WbAOkKfPqY5peLhcdsXrPLeUzcskoMU',
        authorization: nil,
        application_name: 'everydaymusic',
        application_version: '1.0.0'
    )
    youtube = client.discovered_api('youtube', 'v3')

    users = User.all
    # いちいちDBに問い合わせず、一括でとってきてhash だけloopするようにする。
    users.each do |user|
      random_offset = rand(user.artists.count)
      artist = user.artists.offset(random_offset).first
      p artist

      search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => {
              part: 'id',
              type: 'video',
              q: 'manic street preachers',
              maxResults: 1
          }
      )

      p search_response
    end
    return
  end

  InsertIntoDeliveries.execute
end