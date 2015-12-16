class DeliveryMailer < ApplicationMailer

  default from: 'info@everydaymusic.net',
          subject: 'everydaymusic'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.delivery_mailer.sendmail.subject
  #
  def sendmail(email, video_id)
    @video_id = video_id
    mail to: email
    # mail to: email,
    #      body: "https://www.youtube.com/watch?v=#{video_id}"
  end
end
