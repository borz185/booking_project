class Hotel < ApplicationRecord
  self.primary_key = 'hotel_id'
  
  # Валидации
  validates :name, presence: true, length: { maximum: 150 }
  validates :city, presence: true
  validates :country, presence: true
  validates :address, presence: true
  validates :stars, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  
  # Связи
  has_many :rooms, foreign_key: 'hotel_id', primary_key: 'hotel_id', dependent: :destroy
  
  # Методы
  def available_rooms
    rooms.where(is_available: true)
  end
  
  def average_price
    rooms.average(:price_per_night)
  end
end