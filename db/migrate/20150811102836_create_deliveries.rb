class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :video_id, null: false, index: true
      t.boolean :is_delivered, null: false, default: 0

      t.timestamps null: false
    end
  end
end
