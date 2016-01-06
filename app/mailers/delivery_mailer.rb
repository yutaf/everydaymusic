class DeliveryMailer < ApplicationMailer

  default from: 'info@everydaymusic.net',
          subject: 'everydaymusic'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.delivery_mailer.sendmail.subject
  #
  def sendmail(email, video_id, unsubscribe_key)
    @video_id = video_id
    @unsubscribe_url = url_for(host: '192.168.11.92.xip.io', controller: :unsubscribe, action: :index) + "?key=#{unsubscribe_key}"

    mail to: email
    # mail to: email,
    #      body: "https://www.youtube.com/watch?v=#{video_id}"
  end
end
