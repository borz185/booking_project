class PasswordResetMailer < ApplicationMailer
  default from: 'vladimir.borz.185@yandex.ru'

  def send_code(email, code)
    @code = code
    mail(to: email, subject: 'Код восстановления пароля - Booking.ru')
  end
end