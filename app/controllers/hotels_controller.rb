class HotelsController < ApplicationController
  def index
    @hotels = Hotel.all
    
    # Расширенная фильтрация
    # По названию отеля
    if params[:hotel_name].present?
      @hotels = @hotels.where("hotels.name ILIKE ?", "%#{params[:hotel_name]}%")
    end
    
    # По городу
    if params[:city].present?
      @hotels = @hotels.where("hotels.city ILIKE ?", "%#{params[:city]}%")
    end
    
    # По стране
    if params[:country].present?
      @hotels = @hotels.where("hotels.country ILIKE ?", "%#{params[:country]}%")
    end
    
    # По адресу
    if params[:address].present?
      @hotels = @hotels.where("hotels.address ILIKE ?", "%#{params[:address]}%")
    end
    
    # По звёздам
    if params[:stars].present?
      stars_array = params[:stars].reject(&:blank?).map(&:to_i)
      if stars_array.any?
        @hotels = @hotels.where(stars: stars_array)
      end
    end
    
    # По визе
    if params[:visa_required].present? && params[:visa_required] != 'all'
      @hotels = @hotels.where(visa_required: params[:visa_required] == 'true')
    end
    
    # Фильтрация по номерам
    has_search_params = params[:check_in].present? || params[:room_type].present? || 
                        params[:min_price].present? || params[:max_price].present? ||
                        params[:amenities].present? || params[:capacity].present?
    
    if has_search_params
      available_rooms = Room.all
      
      # По датам и гостям
      if params[:check_in].present? && params[:check_out].present? && params[:guests].present?
        available_rooms = Room.available_for_dates(
          params[:check_in],
          params[:check_out],
          params[:guests].to_i
        )
      end
      
      # По типу номера
      if params[:room_type].present?
        available_rooms = available_rooms.where("room_type ILIKE ?", "%#{params[:room_type]}%")
      end
      
      # По цене от
      if params[:min_price].present?
        available_rooms = available_rooms.where("price_per_night >= ?", params[:min_price].to_f)
      end
      
      # По цене до
      if params[:max_price].present?
        available_rooms = available_rooms.where("price_per_night <= ?", params[:max_price].to_f)
      end
      
      # По вместимости
      if params[:capacity].present?
        available_rooms = available_rooms.where("capacity >= ?", params[:capacity].to_i)
      end
      
      # По удобствам
      if params[:amenities].present?
        amenities_array = params[:amenities].split(',').map(&:strip).reject(&:blank?)
        if amenities_array.any?
          amenities_array.each do |amenity|
            available_rooms = available_rooms.where("amenities @> ARRAY[?]::text[]", amenity.downcase)
          end
        end
      end
      
      # Получаем ID отелей с подходящими номерами
      hotel_ids = available_rooms.pluck(:hotel_id).uniq
      @hotels = @hotels.where(hotel_id: hotel_ids) if hotel_ids.any?
    end
    
    # Пагинация
    @hotels = @hotels.page(params[:page]).per(5)
    
    # Сохраняем параметры поиска
    @search_params = params.permit(
      :check_in, :check_out, :guests, :hotel_name, :city, :country, :address,
      :room_type, :capacity, :min_price, :max_price, :visa_required, :amenities,
      stars: []
    )
    
    # Считаем доступные номера для каждого отеля
    @available_rooms_counts = {}
    @hotels.each do |hotel|
      @available_rooms_counts[hotel.hotel_id] = hotel.rooms.count
    end
  end
  
  def show
    @hotel = Hotel.find(params[:id])
  end
end