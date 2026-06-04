class PasswordResetsController < ApplicationController
  def new
  end

  def create
    email = params[:email]&.downcase&.strip
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    # Проверка email
    user = User.find_by(email: email)
    unless user
      flash.now[:alert] = "Пользователь с таким email не найден"
      render :new, status: :unprocessable_entity
      return
    end

    # Проверка паролей
    if password.blank? || password_confirmation.blank?
      flash.now[:alert] = "Пароль не может быть пустым"
      render :new, status: :unprocessable_entity
      return
    end

    if password != password_confirmation
      flash.now[:alert] = "Пароли не совпадают"
      render :new, status: :unprocessable_entity
      return
    end

    if password.length < 6
      flash.now[:alert] = "Пароль должен содержать минимум 6 символов"
      render :new, status: :unprocessable_entity
      return
    end

    # Обновляем пароль
    if user.update(password: password, password_confirmation: password_confirmation)
      # Автоматическая авторизация после сброса пароля
      session[:user_id] = user.user_id
      session[:user_role] = user.role
      
      redirect_to root_path, notice: "Пароль успешно изменен! Добро пожаловать, #{user.username}!"
    else
      flash.now[:alert] = "Ошибка при изменении пароля: #{user.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end
end