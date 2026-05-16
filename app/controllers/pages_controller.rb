class PagesController < ApplicationController
  def home
    @hotels = Hotel.limit(3)
  end
  
  def hotels
    # Все отели для страницы отелей
    @hotels = Hotel.all
    # Фильтрация по параметрам
    # @hotels = Hotel.filter_by(params[:check_in], params[:check_out], params[:guests])
  end
  
  def favorites
    
  end
end