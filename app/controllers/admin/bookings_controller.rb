module Admin
  class BookingsController < AdminController
    before_action :set_booking, only: [:update_status, :destroy]
    
    def index
      @bookings = Booking.includes(:user, room: :hotel)
      
      # Поиск по ID бронирования, имени пользователя, email, названию отеля
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @bookings = @bookings.joins(:user, room: :hotel)
                            .where(
                              "bookings.booking_id::text ILIKE ? OR 
                              users.username ILIKE ? OR 
                              users.email ILIKE ? OR 
                              hotels.name ILIKE ?",
                              search_term, search_term, search_term, search_term
                            )
      end
      
      # Фильтрация по статусу
      if params[:status].present?
        @bookings = @bookings.where(status: params[:status])
      end
      
      @bookings = @bookings.order(created_at: :desc)
                          .page(params[:page]).per(20)
      
      @status_filter = params[:status]
    end
    
    def update
      @booking = Booking.find(params[:id])
      if @booking.update(status: params[:booking][:status])
        redirect_to request.referer || admin_bookings_path, notice: "Статус бронирования обновлен"
      else
        redirect_to request.referer || admin_bookings_path, alert: "Ошибка при обновлении"
      end
    end

    def update_status
      old_status = @booking.status
      new_status = params[:status]
      
      if @booking.update(status: new_status)
        if new_status == 'confirmed' || new_status == 'completed'
          message = "Статус изменен на '#{booking_status_translation(new_status)}'. Доход: #{@booking.calculate_commission}₽"
        elsif old_status == 'confirmed' || old_status == 'completed'
          message = "Статус изменен на '#{booking_status_translation(new_status)}'. Доход удален."
        else
          message = "Статус изменен на '#{booking_status_translation(new_status)}'"
        end
        
        redirect_to admin_bookings_path, notice: message
      else
        redirect_to admin_bookings_path, alert: "Не удалось изменить статус"
      end
    end
    
    def destroy
      @booking.destroy
      redirect_to request.referer || admin_bookings_path, notice: "Бронирование удалено"
    end
    
    private
    
    def set_booking
      @booking = Booking.find(params[:id])
    end
    
    def booking_status_translation(status)
      case status
      when 'pending' then 'Ожидает подтверждения'
      when 'confirmed' then 'Подтверждено'
      when 'completed' then 'Завершено'
      when 'cancelled' then 'Отменено'
      else status
      end
    end
  end  # ← end класса
end  # ← end модуля