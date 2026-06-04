class PasswordResetsController < ApplicationController
  def new
    flash.discard
  end

  def send_code
    email = params[:email]&.downcase&.strip
    
    # Валидация email
    if email.blank? || !email.match?(/\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z/)
      flash.now[:alert] = "Введите корректный email"
      render :new, status: :unprocessable_entity
      return
    end
    
    # Проверяем существование пользователя
    user = User.find_by(email: email)
    unless user
      flash.now[:alert] = "Пользователь с таким email не найден"
      render :new, status: :unprocessable_entity
      return
    end
    
    # Генерируем 4-значный код
    code = rand(1000..9999).to_s
    
    # Сохраняем код и email в сессии с временем создания
    session[:reset_email] = email
    session[:reset_code] = code
    session[:reset_code_sent_at] = Time.current.to_i
    
    # Отправляем письмо
    PasswordResetMailer.send_code(email, code).deliver_now
    
    # Переходим на шаг 2 - ввод кода
    render :enter_code
  end

  def verify_code
    entered_code = params[:code]&.strip
    
    # Проверяем наличие сессии
    unless session[:reset_email] && session[:reset_code]
      flash.now[:alert] = "Сессия истекла. Начните сначала."
      render :new, status: :unprocessable_entity
      return
    end
    
    # Проверяем время жизни кода (10 минут)
    code_age = Time.current.to_i - session[:reset_code_sent_at]
    if code_age > 600
      session.delete(:reset_email)
      session.delete(:reset_code)
      session.delete(:reset_code_sent_at)
      flash.now[:alert] = "Код истек. Запросите новый."
      render :enter_code, status: :unprocessable_entity
      return
    end
    
    # Проверяем код
    if entered_code == session[:reset_code]
      # Код верный - переходим на шаг 3 - ввод нового пароля
      render :new_password
    else
      flash.now[:alert] = "Неверный код. Попробуйте ещё раз."
      render :enter_code, status: :unprocessable_entity
    end
  end

  def update_password
    # Проверяем наличие сессии
    unless session[:reset_email]
      flash.now[:alert] = "Сессия истекла. Начните сначала."
      render :new, status: :unprocessable_entity
      return
    end
    
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    # Валидация пароля
    if password.blank?
      flash.now[:alert] = "Пароль не может быть пустым"
      render :new_password, status: :unprocessable_entity
      return
    end
    
    if password.length < 6
      flash.now[:alert] = "Пароль должен содержать минимум 6 символов"
      render :new_password, status: :unprocessable_entity
      return
    end
    
    if password != password_confirmation
      flash.now[:alert] = "Пароли не совпадают"
      render :new_password, status: :unprocessable_entity
      return
    end
    
    # Находим пользователя и обновляем пароль
    user = User.find_by(email: session[:reset_email])
    unless user
      flash.now[:alert] = "Пользователь не найден"
      render :new, status: :unprocessable_entity
      return
    end
    
    if user.update(password: password, password_confirmation: password_confirmation)
      # Очищаем сессию восстановления
      session.delete(:reset_email)
      session.delete(:reset_code)
      session.delete(:reset_code_sent_at)
      
      # Автоматическая авторизация
      session[:user_id] = user.user_id
      session[:user_role] = user.role
      
      redirect_to root_path, notice: "Пароль успешно изменён! Добро пожаловать, #{user.username}!"
    else
      flash.now[:alert] = "Ошибка при изменении пароля: #{user.errors.full_messages.to_sentence}"
      render :new_password, status: :unprocessable_entity
    end
  end
end