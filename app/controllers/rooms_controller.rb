class RoomsController < ApplicationController
  before_action :set_hotel
  before_action :require_login, only: [:index]
  
  def index
    @rooms = @hotel.rooms
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