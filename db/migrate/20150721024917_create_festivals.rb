class CreateFestivals < ActiveRecord::Migration
  def change
    create_table :festivals do |t|
      t.string :name
      t.string :title

      t.timestamps null: false
    end
  end
end
