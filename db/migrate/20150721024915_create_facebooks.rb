class CreateFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.references :user, foreign_key: true, null: false
      t.string :facebook_user_id, null: false

      t.timestamps null: false
    end
    add_index :facebooks, [:user_id, :facebook_user_id], unique: true
  end
end
