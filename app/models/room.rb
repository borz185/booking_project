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
end