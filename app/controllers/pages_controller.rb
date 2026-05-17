class PagesController < ApplicationController
  def home
    @hotels = Hotel.limit(3)
  end
  
  def hotels
    # Хеш для хранения количества доступных номеров
    @available_rooms_counts = {}

    if params[:check_in].present? && params[:check_out].present? && params[:guests].present?
      # 1. Находим все доступные номера
      available_rooms = Room.available_for_dates(
        params[:check_in], 
        params[:check_out], 
        params[:guests].to_i
      )

      # 2. Получаем уникальные ID отелей
      hotel_ids = available_rooms.pluck(:hotel_id).uniq

      # 3. Загружаем отели
      @hotels = Hotel.where(hotel_id: hotel_ids)
      
      # 4. Считаем сколько номеров доступно в каждом отеле
      @hotels.each do |hotel|
        count = available_rooms.where(hotel_id: hotel.hotel_id).count
        @available_rooms_counts[hotel.hotel_id] = count
      end
      
      @search_params = params.permit(:check_in, :check_out, :guests)
    else
      # Если поиска нет, показываем все отели и считаем все их номера
      @hotels = Hotel.all
      @hotels.each { |h| @available_rooms_counts[h.hotel_id] = h.rooms.count }
      @search_params = {}
    end
  end
  
  def favorites
    
  end
end