class AuthController < ApplicationController
  def signup
    # Страница регистрации
  end
  
  def login
    # Страница входа
  end
  
  def register
    # Регистрация
    redirect_to root_path
  end
  
  def authenticate
    # Аутентификация
    redirect_to root_path
  end
  
  def logout
    # Выход
    redirect_to root_path
  end
end
