class PagesController < ApplicationController
  def home
    @hotels = Hotel.limit(3)
  end
  
  def hotels
    @available_rooms_counts = {}
    @hotels = Hotel.all
    
    # Фильтрация по названию отеля
    if params[:hotel_name].present?
      @hotels = @hotels.where("hotels.name ILIKE ?", "%#{params[:hotel_name]}%")
    end
    
    # Фильтрация по городу
    if params[:city].present?
      @hotels = @hotels.where("hotels.city ILIKE ?", "%#{params[:city]}%")
    end
    
    # Фильтрация по стране
    if params[:country].present?
      @hotels = @hotels.where("hotels.country ILIKE ?", "%#{params[:country]}%")
    end
    
    # Фильтрация по адресу
    if params[:address].present?
      @hotels = @hotels.where("hotels.address ILIKE ?", "%#{params[:address]}%")
    end
    
    # Фильтрация по звёздам
    if params[:stars].present?
      stars_array = params[:stars].reject(&:blank?).map(&:to_i)
      if stars_array.any?
        @hotels = @hotels.where(stars: stars_array)
      end
    end
    
    # Фильтрация по визе
    if params[:visa_required].present? && params[:visa_required] != 'all'
      @hotels = @hotels.where(visa_required: params[:visa_required] == 'true')
    end
    
    # Фильтрация по номерам
    has_search_params = params[:check_in].present? || params[:room_type].present? || 
                        params[:min_price].present? || params[:max_price].present? ||
                        params[:amenities].present?
    
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
      
      # По удобствам
      if params[:amenities].present?
        amenities_array = params[:amenities].split(',').map(&:strip).reject(&:blank?)
        if amenities_array.any?
          amenities_array.each do |amenity|
            available_rooms = available_rooms.where("amenities @> ARRAY[?]::varchar[]", amenity.downcase)
          end
        end
      end
      
      # Получаем ID отелей с подходящими номерами
      hotel_ids = available_rooms.pluck(:hotel_id).uniq
      @hotels = @hotels.where(hotel_id: hotel_ids) if hotel_ids.any?
      
      # Считаем доступные номера для каждого отеля
      @hotels.each do |hotel|
        @available_rooms_counts[hotel.hotel_id] = available_rooms.where(hotel_id: hotel.hotel_id).count
      end
    else
      # Если нет параметров поиска по номерам, считаем все номера
      @hotels.each do |hotel|
        @available_rooms_counts[hotel.hotel_id] = hotel.rooms.count
      end
    end
    
    # Пагинация
    @hotels = @hotels.page(params[:page]).per(5)
    
    # Сохраняем параметры поиска
    @search_params = params.permit(
      :check_in, :check_out, :guests, :hotel_name, :city, :country, :address,
      :room_type, :min_price, :max_price, :visa_required, :amenities,
      stars: []
    )
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          hotels: @hotels.map { |h| 
            {
              id: h.hotel_id,
              name: h.name,
              city: h.city,
              country: h.country,
              address: h.address,
              stars: h.stars,
              description: h.description,
              phone: h.phone,
              visa_required: h.visa_required,
              has_main_photo: h.has_main_photo?,
              main_photo_url: h.has_main_photo? ? url_for(h.main_photo.variant(resize_to_fill: [400, 300])) : nil,
              available_rooms_count: @available_rooms_counts[h.hotel_id] || 0
            }
          },
          has_next: @hotels.current_page < @hotels.total_pages,
          next_page: @hotels.current_page < @hotels.total_pages ? @hotels.current_page + 1 : nil,
          total_pages: @hotels.total_pages,
          current_page: @hotels.current_page
        }
      end
    end
  end
  
  def favorites
  end
end