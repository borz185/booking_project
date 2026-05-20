module Admin
  class BookingsController < AdminController
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
        # request.referer возвращает на страницу, откуда пришел запрос
        redirect_to request.referer || admin_bookings_path, notice: "Статус бронирования обновлен"
      else
        redirect_to request.referer || admin_bookings_path, alert: "Ошибка при обновлении"
      end
    end
    
    def destroy
      @booking = Booking.find(params[:id])
      @booking.destroy
      # request.referer возвращает на страницу, откуда пришел запрос
      redirect_to request.referer || admin_bookings_path, notice: "Бронирование удалено"
    end
  end
end