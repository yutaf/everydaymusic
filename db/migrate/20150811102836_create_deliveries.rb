class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.datetime :date
      t.references :user, index: true, foreign_key: true
      t.string :video_id, index: true

      t.timestamps null: false
    end
  end
end
