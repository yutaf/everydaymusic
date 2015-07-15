class CreateFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.references :user, index: true, foreign_key: true
      t.string :facebook_user_id
      t.string :accessToken
      t.string :salt

      t.timestamps null: false
    end
  end
end
