class Room < ApplicationRecord
  self.primary_key = 'room_id'
  
  # Валидации
  validates :room_number, presence: true
  validates :room_type, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :price_per_night, numericality: { greater_than: 0 }
  validates :hotel_id, presence: true
  
  # Связи
  belongs_to :hotel, foreign_key: 'hotel_id', primary_key: 'hotel_id'
  has_many :bookings, foreign_key: 'room_id', primary_key: 'room_id', dependent: :restrict_with_error
  
  # Методы
  def available_for?(check_in, check_out)
    is_available && !bookings.where(status: ['pending', 'confirmed'])
      .where('(check_in_date <= ? AND check_out_date >= ?) OR 
              (check_in_date <= ? AND check_out_date >= ?) OR
              (check_in_date >= ? AND check_out_date <= ?)',
             check_out, check_in,
             check_out, check_in,
             check_in, check_out)
      .exists?
  end

  # Класс-метод для поиска доступных номеров
  # check_in_date, check_out_date - строки 'YYYY-MM-DD'
  # guests - integer
  def self.available_for_dates(check_in, check_out, guests)
    # 1. Базовая фильтрация: номер должен быть доступен и вмещать гостей
    query = where(is_available: true).where('capacity >= ?', guests)

    # 2. Исключаем номера, которые уже забронированы на эти даты
    # Бронь пересекается, если: (ЗаездБрони <= ВыездПоиска) И (ВыездБрони >= ЗаездПоиска)
    busy_room_ids = Booking.where(status: ['pending', 'confirmed'])
                           .where('check_in_date <= ? AND check_out_date >= ?', check_out, check_in)
                           .pluck(:room_id)

    if busy_room_ids.any?
      query = query.where.not(room_id: busy_room_ids)
    end

    query
  end
end