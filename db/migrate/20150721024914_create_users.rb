class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :locale
      t.integer :timezone, limit: 1
      t.time :delivery_time
      t.boolean :is_active, null: false, default: 1

      t.timestamps null: false
    end
  end
end
