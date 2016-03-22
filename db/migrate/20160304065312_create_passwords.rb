class CreatePasswords < ActiveRecord::Migration
  def change
    create_table :passwords do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end
  end
end
