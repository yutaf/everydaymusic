class DeliveryJob < ActiveJob::Base
  queue_as :delivery

  def perform

    require 'sidekiq/api'

    # clear scheduled delivery ques
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.queue == 'delivery' }
    jobs.each(&:delete)
    # Set next schedule
    self.class.set(wait: 1.hour).perform_later

    DeliveryCore.deliver
  end
end
