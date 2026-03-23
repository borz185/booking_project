class Booking < ApplicationRecord
  self.primary_key = 'booking_id'
  
  # Валидации
  validates :check_in_date, presence: true
  validates :check_out_date, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validates :guests_count, numericality: { greater_than: 0 }
  validate :check_out_after_check_in
  
  # ENUM для статуса
  enum :status, { pending: 'pending', confirmed: 'confirmed', cancelled: 'cancelled', completed: 'completed' }, prefix: true
  
  # Связи
  belongs_to :user, foreign_key: 'user_id', primary_key: 'user_id'
  belongs_to :room, foreign_key: 'room_id', primary_key: 'room_id'
  has_one :payment, foreign_key: 'booking_id', primary_key: 'booking_id', dependent: :destroy
  
  # Методы
  def nights_count
    (check_out_date - check_in_date).to_i
  end
  
  def total_with_payment
    payment&.amount || total_price
  end
  
  private
  
  def check_out_after_check_in
    if check_out_date && check_in_date && check_out_date <= check_in_date
      errors.add(:check_out_date, 'должна быть позже даты заезда')
    end
  end
end