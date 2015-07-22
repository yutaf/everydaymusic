class AddIndexToFestivals < ActiveRecord::Migration
  def change
    add_index :festivals, :name, unique: true
  end
end
