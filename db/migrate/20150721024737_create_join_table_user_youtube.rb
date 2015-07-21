class CreateJoinTableUserYoutube < ActiveRecord::Migration
  def change
    create_join_table :users, :youtubes do |t|
      # t.index [:user_id, :youtube_id]
      # t.index [:youtube_id, :user_id]
      t.references :delivery
    end
  end
end
