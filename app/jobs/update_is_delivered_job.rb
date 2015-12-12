class UpdateIsDeliveredJob < ActiveJob::Base
  queue_as :update_is_delivered

  def perform(id)
    delivery = Delivery.find(id)
    delivery.update(is_delivered: true)
  end
end
