class RoomsController < ApplicationController
  before_action :set_hotel
  before_action :require_login, only: [:index]
  
  def index
    # Если переданы параметры поиска — фильтруем номера
    if params[:check_in].present? && params[:check_out].present? && params[:guests].present?
      @rooms = Room.available_for_dates(
        params[:check_in],
        params[:check_out],
        params[:guests].to_i
      ).where(hotel_id: @hotel.hotel_id)
      
      @search_params = params.permit(:check_in, :check_out, :guests)
    else
      @rooms = @hotel.rooms
      @search_params = {}
    end
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