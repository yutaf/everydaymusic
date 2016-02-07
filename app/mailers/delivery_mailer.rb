class DeliveryMailer < ApplicationMailer

  default from: 'everydaymusic <notifications@everydaymusic.net>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.delivery_mailer.sendmail.subject
  #
  def sendmail(email, delivery_id, unsubscribe_key, locale, title, timestamp)
    @delivery_url = url_for(controller: :deliveries, action: :show, id: delivery_id, only_path: false)
    @title = title
    date = Time.at(timestamp)

    if locale.blank?
      locale = ENV['DEFAULT_LOCALE']
    end
    locale = locale[0,2]
    case locale
      when 'ja', 'en'
        ;
      else
        locale = 'en'
    end
    I18n.locale = locale

    query = "?key=#{unsubscribe_key}&locale=#{locale}"
    @unsubscribe_url = url_for(controller: :unsubscribe, action: :index, only_path: false) + query

    subject = "#{l date, format: :short, day: date.day.ordinalize} #{t 'delivery_mail.update'}"
    mail to: email, subject: subject
  end
end
