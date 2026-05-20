module Admin
  class RoomsController < AdminController
    before_action :set_hotel
    before_action :set_room, only: [:show, :edit, :update, :destroy]
    
    def index
      @rooms = @hotel.rooms
      
      # Поиск по номеру комнаты, типу
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @rooms = @rooms.where(
          "room_number ILIKE ? OR room_type ILIKE ? OR description ILIKE ?",
          search_term, search_term, search_term
        )
      end
      
      @rooms = @rooms.order(room_number: :asc)
                    .page(params[:page]).per(20)
    end
    
    def show
    end
    
    def new
      @room = @hotel.rooms.new
    end
    
    def create
      @room = @hotel.rooms.new(room_params.except(:amenities_input))
      
      # Обработка удобств
      if params[:room][:amenities_input].present?
        amenities = params[:room][:amenities_input].split(',').map(&:strip).reject(&:blank?)
        @room.amenities = amenities
      end
      
      if @room.save
        # Загрузка фото (максимум 3)
        if params[:room][:photos].present?
          params[:room][:photos].first(3).each do |photo|
            @room.photos.attach(photo) if photo.present?
          end
        end
        redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер успешно создан"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def edit
    end
    
    def update
      @room.assign_attributes(room_params.except(:amenities_input))
      
      # Обновление удобств
      if params[:room][:amenities_input].present?
        amenities = params[:room][:amenities_input].split(',').map(&:strip).reject(&:blank?)
        @room.amenities = amenities
      end
      
      if @room.save
        # Обновление фото
        if params[:room][:photos].present?
          @room.photos.purge_all
          params[:room][:photos].first(3).each do |photo|
            @room.photos.attach(photo) if photo.present?
          end
        end
        redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер успешно обновлен"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @room.destroy
      redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер удалён"
    end
    
    private
    
    def set_hotel
      @hotel = Hotel.find(params[:hotel_id])
    end
    
    def set_room
      @room = @hotel.rooms.find(params[:id])
    end
    
    def room_params
      params.require(:room).permit(
        :room_number, :room_type, :capacity, :price_per_night,
        :description, :is_available, :amenities_input, photos: []
      )
    end
  end
end