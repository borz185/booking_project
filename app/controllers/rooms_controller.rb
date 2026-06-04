class RoomsController < ApplicationController
  before_action :set_hotel
  before_action :require_login, only: [:index]

  def index
    @rooms = @hotel.rooms
    
    # Собираем ВСЕ параметры поиска
    @search_params = params.permit(
      :check_in, :check_out, :guests, 
      :room_type, :min_price, :max_price, :amenities,
      :hotel_name, :city, :country, :address, :visa_required,
      stars: []
    )
    
    # Фильтрация по датам и гостям
    if params[:check_in].present? && params[:check_out].present? && params[:guests].present?
      @rooms = Room.available_for_dates(
        params[:check_in],
        params[:check_out],
        params[:guests].to_i
      ).where(hotel_id: @hotel.hotel_id)
    end
    
    # Фильтрация по типу номера
    if params[:room_type].present?
      @rooms = @rooms.where("room_type ILIKE ?", "%#{params[:room_type]}%")
    end
    
    # Фильтрация по цене от
    if params[:min_price].present?
      @rooms = @rooms.where("price_per_night >= ?", params[:min_price].to_f)
    end
    
    # Фильтрация по цене до
    if params[:max_price].present?
      @rooms = @rooms.where("price_per_night <= ?", params[:max_price].to_f)
    end
    
    # По удобствам
    if params[:amenities].present?
      amenities_array = params[:amenities].split(',').map(&:strip).reject(&:blank?)
      if amenities_array.any?
        amenities_array.each do |amenity|
          # Исправлено: явно указываем тип varchar[]
          @rooms = @rooms.where("amenities @> ARRAY[?]::varchar[]", amenity.downcase)
        end
      end
    end
    
    @rooms = @rooms.order(room_number: :asc)
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:hotel_id])
  end

  def require_login
    unless logged_in?
      redirect_to login_path(return_to: request.original_fullpath),
                  alert: "Пожалуйста, войдите для просмотра номеров"
    end
  end
end