class DeliveryMailer < ApplicationMailer

  default from: 'info@everydaymusic.net',
          subject: 'everydaymusic'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.delivery_mailer.sendmail.subject
  #
  def sendmail(email, video_id, unsubscribe_key, locale)
    @video_id = video_id

    if locale.blank?
      locale = ENV['DEFAULT_LOCALE']
    end
    locale = locale[0,2]
    query = "?key=#{unsubscribe_key}&locale=#{locale}"
    #TODO Fix host value
    @unsubscribe_url = url_for(host: '192.168.11.92.xip.io', controller: :unsubscribe, action: :index) + query

    I18n.locale = locale

    mail to: email
  end
end
