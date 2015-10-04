class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ''
      t.string :locale, null: false, default: ENV['DEFAULT_LOCALE']
      t.integer :timezone, limit: 1, null: false, default: 0
      t.time :delivery_time, null: false, default: ENV['DEFAULT_DELIVERY_TIME']
      t.boolean :is_active, null: false, default: 1

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
