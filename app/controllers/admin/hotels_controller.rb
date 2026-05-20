module Admin
  class HotelsController < AdminController
    before_action :set_hotel, only: [:show, :edit, :update, :destroy]
    
    def index
      @hotels = Hotel.all
      
      # Поиск по названию, городу, стране
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @hotels = @hotels.where(
          "name ILIKE ? OR city ILIKE ? OR country ILIKE ?",
          search_term, search_term, search_term
        )
      end
      
      @hotels = @hotels.order(created_at: :desc)
                       .page(params[:page]).per(20)
    end
    
    def show
    end
    
    def new
      @hotel = Hotel.new
    end
    
    def create
      @hotel = Hotel.new(hotel_params)
      if @hotel.save
        # Загрузка главного фото
        if params[:hotel][:main_photo].present?
          @hotel.main_photo.attach(params[:hotel][:main_photo])
        end
        redirect_to admin_hotels_path, notice: "Отель успешно создан"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      if @hotel.update(hotel_params.except(:main_photo))
        # Обновление главного фото
        if params[:hotel][:main_photo].present?
          @hotel.main_photo.purge if @hotel.main_photo.attached?
          @hotel.main_photo.attach(params[:hotel][:main_photo])
        end
        redirect_to admin_hotels_path, notice: "Отель успешно обновлен"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @hotel.destroy
      redirect_to admin_hotels_path, notice: "Отель удалён"
    end
    
    private
    
    def set_hotel
      @hotel = Hotel.find(params[:id])
    end
    
    def hotel_params
      params.require(:hotel).permit(
        :name, :city, :country, :address, :stars, :description, 
        :phone, :visa_required, :main_photo
      )
    end
  end
end