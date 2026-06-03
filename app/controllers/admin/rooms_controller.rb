module Admin
  class RoomsController < AdminController
    before_action :set_hotel
    before_action :set_room, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, only: [:remove_photo]
    
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
  
  if params[:room][:amenities_input].present?
    @room.amenities = params[:room][:amenities_input].split(',').map(&:strip).reject(&:blank?)
  end
  
  # Загружаем фото (максимум 3)
  if params[:room][:photos].present?
    uploaded_photos = params[:room][:photos].to_a.reject(&:blank?)
    @room.photos.attach(uploaded_photos.first(3))
  end
  
  if @room.save
    redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер успешно создан"
  else
    render :new, status: :unprocessable_entity
  end
end

def update
  @room.assign_attributes(room_params.except(:amenities_input))
  
  if params[:room][:amenities_input].present?
    @room.amenities = params[:room][:amenities_input].split(',').map(&:strip).reject(&:blank?)
  end
  
  # 🔹 При загрузке новых фото - старые удаляются автоматически
  if params[:room][:photos].present?
    uploaded_photos = params[:room][:photos].to_a.reject(&:blank?)
    
    if uploaded_photos.any?
      # Удаляем ВСЕ старые фото
      @room.photos.each(&:purge) if @room.photos.attached?
      
      # Прикрепляем новые (максимум 3)
      @room.photos.attach(uploaded_photos.first(3))
    end
  end
  
  if @room.save
    redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер успешно обновлен"
  else
    render :edit, status: :unprocessable_entity
  end
end
    
    def edit
    end
    
    def destroy
      @room.destroy
      redirect_to admin_hotel_rooms_path(@hotel), notice: "Номер удалён"
    end

    # Удаление одной фотографии
    def remove_photo
      @room = @hotel.rooms.find(params[:id])
      photo = @room.photos.find(params[:photo_id])
      photo.purge
      redirect_to edit_admin_hotel_room_path(@hotel, @room), notice: "Фотография удалена"
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_admin_hotel_room_path(@hotel, @room), alert: "Фотография не найдена"
    end
    
    # Удаление ВСЕХ фотографий
    def clear_photos
      @room = @hotel.rooms.find(params[:id])
      @room.photos.purge_all
      redirect_to edit_admin_hotel_room_path(@hotel, @room), notice: "Все фотографии удалены"
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_admin_hotel_room_path(@hotel, @room), alert: "Номер не найден"
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
        :description, :is_available, :amenities_input
      )
    end
  end
end