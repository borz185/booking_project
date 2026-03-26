class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # Хелперы для доступа к текущему пользователю
  helper_method :current_user
  helper_method :logged_in?
  helper_method :admin?
  
  private
  
  def current_user
    @current_user ||= User.find_by(user_id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    current_user.present?
  end
  
  def admin?
    current_user&.role_admin?
  end
end
