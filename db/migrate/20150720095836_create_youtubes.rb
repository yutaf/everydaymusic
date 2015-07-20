class CreateYoutubes < ActiveRecord::Migration
  def change
    create_table :youtubes do |t|
      t.string :videoId
      t.string :title

      t.timestamps null: false
    end
  end
end
