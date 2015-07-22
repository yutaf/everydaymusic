class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :locale
      t.integer :timezone
      t.integer :fetch_cnt
      t.time :delivery_time
      t.integer :interval
      t.boolean :is_active

      t.timestamps null: false
    end
  end
end