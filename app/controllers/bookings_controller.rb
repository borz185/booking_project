class BookingsController < ApplicationController
  before_action :require_login
  before_action :set_booking, only: [:show, :cancel]

  def index
    @bookings = Booking.where(user_id: current_user.user_id)
                       .includes(room: :hotel)
                       .order(created_at: :desc)
  end

  def show
    redirect_to bookings_path, alert: "Доступ запрещен" unless @booking.user_id == current_user.user_id
  end

  def cancel
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

  # Новый метод создания бронирования (AJAX)
  def create
    room = Room.find(params[:room_id])
    
    # Проверка: требует ли отель визу и есть ли она у пользователя
    if room.hotel.visa_required && !current_user.has_visa
      render json: { 
        success: false, 
        errors: ["Этот отель требует визу. Пожалуйста, получите визу перед бронированием."] 
      }, status: :unprocessable_entity
      return
    end

    # Парсим даты
    check_in = Date.parse(params[:check_in_date])
    check_out = Date.parse(params[:check_out_date])
    guests = params[:guests_count].to_i

    # Проверка: свободен ли номер на эти даты
    if room.available_for?(check_in, check_out) && guests <= room.capacity
      nights = (check_out - check_in).to_i
      total_price = nights * room.price_per_night

      booking = current_user.bookings.new(
        room: room,
        check_in_date: check_in,
        check_out_date: check_out,
        guests_count: guests,
        total_price: total_price,
        status: 'pending' # Статус "Ожидает подтверждения"
      )

      if booking.save
        render json: { success: true, booking_id: booking.booking_id }, status: :created
      else
        render json: { success: false, errors: booking.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { success: false, errors: ["Номер недоступен на выбранные даты или превышает вместимость"] }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Пожалуйста, войдите для просмотра бронирований"
    end
  end
end