class KickDeliveryJob
  def self.execute
    DeliveryJob.perform_later
  end
  self.execute
end