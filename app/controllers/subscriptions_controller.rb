class SubscriptionsController < ApplicationController
  def create
    email = params[:email]&.strip
    agreement = params[:agreement]
    
    # Проверка согласия
    unless agreement == '1'
      redirect_back fallback_location: root_path, 
                    alert: "Для подписки необходимо дать согласие на получение рассылки"
      return
    end
    
    # Проверка email
    if email.blank? || !email.match?(/\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z/)
      redirect_back fallback_location: root_path, 
                    alert: "Введите корректный email (например: example@mail.com)"
      return
    end
    
    subscriber = Subscriber.find_or_initialize_by(email: email.downcase)
    
    if subscriber.save
      redirect_back fallback_location: root_path, 
                    notice: "Вы успешно подписались на рассылку!"
    else
      redirect_back fallback_location: root_path, 
                    alert: "#{subscriber.errors.full_messages.first}"
    end
  end
end