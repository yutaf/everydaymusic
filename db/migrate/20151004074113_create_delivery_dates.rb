class CreateDeliveryDates < ActiveRecord::Migration
  def change
    create_table :delivery_dates do |t|
      t.references :delivery, null: false, index: true, foreign_key: true
      t.datetime :date, null: false

      t.timestamps null: false
    end
  end
end
