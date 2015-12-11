class KickDeliveryJob
  def self.execute
    require 'sidekiq/api'

    # clear scheduled delivery ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'delivery' }
    jobs.each(&:delete)

    DeliveryJob.perform_later
  end
  KickDeliveryJob.execute
end