class SessionsController < ApplicationController
  def new
    # Страница входа
  end
  
  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
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
