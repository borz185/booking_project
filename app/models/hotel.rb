class Hotel < ApplicationRecord
  self.primary_key = 'hotel_id'
  
  # Active Storage - одно главное фото
  has_one_attached :main_photo

  # Валидации
  validates :name, presence: true, length: { maximum: 150 }
  validates :city, presence: true
  validates :country, presence: true
  validates :address, presence: true
  validates :stars, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  
  validates :phone, 
            format: { 
              with: /\A[+0-9\s\-()]+\z/, 
              message: "может содержать только цифры, +, скобки или дефисы" 
            },
            allow_blank: true

  # Связи
  has_many :rooms, foreign_key: 'hotel_id', primary_key: 'hotel_id', dependent: :destroy
  has_many :earnings, foreign_key: 'hotel_id', primary_key: 'hotel_id', dependent: :destroy
  
  # Методы
  def available_rooms
    rooms.where(is_available: true)
  end
  
  def average_price
    rooms.average(:price_per_night)
  end

  # Проверка наличия фото
  def has_main_photo?
    main_photo.attached?
  end
end