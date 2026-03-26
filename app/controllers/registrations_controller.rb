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
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :phone)
  end
end