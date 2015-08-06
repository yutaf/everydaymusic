class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.references :user, index: true, foreign_key: true
      t.datetime :delivered_at

      t.timestamps null: false
    end
  end
end
