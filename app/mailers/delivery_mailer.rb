class DeliveryMailer < ApplicationMailer

  default from: 'everydaymusic <notifications@everydaymusic.net>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.delivery_mailer.sendmail.subject
  #
  def sendmail(email, video_id, unsubscribe_key, locale, title, timestamp)
    @video_id = video_id
    @title = title
    date = Time.at(timestamp)

    if locale.blank?
      locale = ENV['DEFAULT_LOCALE']
    end
    locale = locale[0,2]
    query = "?key=#{unsubscribe_key}&locale=#{locale}"
    @unsubscribe_url = url_for(controller: :unsubscribe, action: :index, only_path: false) + query

    I18n.locale = locale

    subject = "#{l date, format: :short, day: date.day.ordinalize} #{t 'delivery_mail.update'}"
    mail to: email, subject: subject
  end
end
