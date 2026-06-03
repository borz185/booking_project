class HotelsController < ApplicationController
  def index
    #@hotels = Hotel.all
    @hotels = Hotel.all.page(params[:page]).per(5)
    
    # Фильтрация
    if params[:check_in].present? && params[:check_out].present? && params[:guests].present?
      available_rooms = Room.available_for_dates(
        params[:check_in],
        params[:check_out],
        params[:guests].to_i
      )
      hotel_ids = available_rooms.pluck(:hotel_id).uniq
      @hotels = Hotel.where(hotel_id: hotel_ids).page(params[:page]).per(5)
      @search_params = params.permit(:check_in, :check_out, :guests)
    end
  end
  
  def show
    @hotel = Hotel.find(params[:id])
  end
end