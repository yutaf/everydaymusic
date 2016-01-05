class KickDeliveryJob
  def self.execute
=begin
    require 'sidekiq/api'

    # clear scheduled delivery ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'delivery' }
    jobs.each(&:delete)
=end

    DeliveryJob.perform_later
  end
  KickDeliveryJob.execute
end