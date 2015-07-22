class CreateFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :facebook_user_id, index: true, null: false

      t.timestamps null: false
    end
  end
end
