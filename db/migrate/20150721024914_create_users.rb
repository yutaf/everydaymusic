class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :locale
      t.integer :timezone
      t.time :delivery_time
      t.boolean :is_active

      t.timestamps null: false
    end
  end
end
