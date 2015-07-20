class CreateJoinTableFestivalUser < ActiveRecord::Migration
  def change
    create_join_table :festivals, :users do |t|
      # t.index [:festival_id, :user_id]
      # t.index [:user_id, :festival_id]
    end
  end
end
