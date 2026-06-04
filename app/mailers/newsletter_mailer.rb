class NewsletterMailer < ApplicationMailer
  default from: 'vladimir.borz.185@yandex.ru' # Замените на ваш реальный email

  def send_to_subscribers(email, message)
    @message = message
    mail(to: email, subject: 'Важная новость от Booking.ru')
  end
end