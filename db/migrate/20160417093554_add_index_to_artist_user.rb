class AddIndexToArtistUser < ActiveRecord::Migration
  def change
    add_index :artists_users, [:artist_id, :user_id], unique: true
  end
end
