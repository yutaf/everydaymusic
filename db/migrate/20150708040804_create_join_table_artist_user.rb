class CreateJoinTableArtistUser < ActiveRecord::Migration
  def change
    create_join_table :artists, :users do |t|
      # t.index [:artist_id, :user_id]
      # t.index [:user_id, :artist_id]
    end
  end
end
