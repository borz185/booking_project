class SessionsController < ApplicationController
  def new
    # Страница входа
  end
  
  def create
    # Нормализация email (lowercase + strip)
    email = params[:email]&.downcase&.strip
    password = params[:password]

    user = User.find_by(email: email)
    
    if user&.authenticate(password)
      # Успешный вход
      session[:user_id] = user.user_id
      session[:user_role] = user.role
      
      redirect_to root_path, notice: "Добро пожаловать, #{user.username}!"
    else
      # Ошибка входа
      flash.now[:alert] = "Неверный email или пароль"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session[:user_id] = nil
    session[:user_role] = nil
    redirect_to root_path, notice: "Вы вышли из системы"
  end
end
