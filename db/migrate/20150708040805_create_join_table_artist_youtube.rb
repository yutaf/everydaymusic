class CreateJoinTableArtistYoutube < ActiveRecord::Migration
  def change
    create_join_table :artists, :youtubes do |t|
      # t.index [:artist_id, :youtube_id]
      # t.index [:youtube_id, :artist_id]
    end
  end
end
