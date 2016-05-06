class RemoveIndexFromDeliveries < ActiveRecord::Migration
  def change
    # Cannot remove foreign key index
    # remove_index(:deliveries, :artist_id)
    remove_index(:deliveries, :video_id)
    remove_index(:deliveries, :title)
  end
end
