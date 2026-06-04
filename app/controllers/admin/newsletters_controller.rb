module Admin
  class NewslettersController < AdminController
    def send_message
      message = params[:message]&.strip
      if message.blank?
        redirect_to admin_root_path, alert: "Введите текст сообщения"
        return
      end

      subscribers = Subscriber.all
      if subscribers.empty?
        redirect_to admin_root_path, alert: "Нет подписчиков для рассылки"
        return
      end

      sent_count = 0
      subscribers.find_each do |subscriber|
        begin
          NewsletterMailer.send_to_subscribers(subscriber.email, message).deliver_now
          sent_count += 1
        rescue => e
          Rails.logger.error "Ошибка отправки письма на #{subscriber.email}: #{e.message}"
        end
      end

      redirect_to admin_root_path
    end
  end
end