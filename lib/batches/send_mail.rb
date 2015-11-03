class DeliveryMailer < ActionMailer::Base
  def first_example
    mail(
        to: 'yutafuji2008@gmail.com',
        from: 'yutafuji2008@gmail.com',
        subject: 'Mail from rails app',
        body: 'Hello, mail'
    )
  end
end

class SendMail
  def self.execute
    DeliveryMailer.first_example.deliver_now
  end

  SendMail.execute
end