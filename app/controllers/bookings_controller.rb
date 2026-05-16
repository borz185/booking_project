class BookingsController < ApplicationController
  before_action :require_login
  
  def index
    # Показываем только бронирования текущего пользователя
    @bookings = Booking.where(user_id: current_user.user_id)
                       .includes(room: :hotel)
                       .order(created_at: :desc)
  end
  
  def show
    @booking = Booking.find(params[:id])
    # Проверка что бронирование принадлежит текущему пользователю
    redirect_to bookings_path, alert: "Доступ запрещен" unless @booking.user_id == current_user.user_id
  end
  
  def cancel
    @booking = Booking.find(params[:id])
    # Проверка что бронирование принадлежит текущему пользователю
    if @booking.user_id == current_user.user_id
      if @booking.status == 'pending' || @booking.status == 'confirmed'
        @booking.update(status: 'cancelled')
        redirect_to bookings_path, notice: "Бронирование отменено"
      else
        redirect_to bookings_path, alert: "Невозможно отменить бронирование с текущим статусом"
      end
    else
      redirect_to bookings_path, alert: "Доступ запрещен"
    end
  end
  
  private
  
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Пожалуйста, войдите для просмотра бронирований"
    end
  end
end