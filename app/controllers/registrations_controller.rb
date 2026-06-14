class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      # Автоматический вход после регистрации
      session[:user_id] = @user.user_id
      session[:user_role] = @user.role
      
      redirect_to root_path, notice: "Регистрация успешна! Добро пожаловать!"
    else
      render :new, status: :unprocessable_entity
    end
    rescue ActiveRecord::RecordNotUnique => e
    # Обработка ошибки уникальности
    if e.message.include?('index_users_on_username')
      @user.errors.add(:username, 'Уже зарегистрирован')
    elsif e.message.include?('index_users_on_email')
      @user.errors.add(:email, 'Уже зарегистрирован')
    end
    render :new, status: :unprocessable_entity
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :phone)
  end
end