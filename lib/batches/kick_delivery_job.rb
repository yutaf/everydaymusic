class KickDeliveryJob
  def self.execute
    DeliveryJob.perform_later
  end
  KickDeliveryJob.execute
end