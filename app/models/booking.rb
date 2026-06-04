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
  has_one :earning, dependent: :destroy
  
  # Callback для создания/удаления earning при смене статуса
  after_update :handle_earning_on_status_change

  # Методы
  # Метод для расчета комиссии
  def calculate_commission
    hotel = room&.hotel
    return 0 unless hotel
    
    commission = (total_price * hotel.commission_rate / 100.0).round(2)
    commission
  end
  
  # Метод для создания записи о доходе
  def create_earning!
    return if earning.present?
    
    commission = calculate_commission
    return if commission <= 0
    
    Earning.create!(
      booking: self,
      hotel: room.hotel,
      amount: commission,
      commission_rate: room.hotel.commission_rate,
      earned_at: created_at
    )
  end

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

  def handle_earning_on_status_change
    # Если статус изменился на confirmed или completed
    if (status_changed? || saved_change_to_status?) && 
       (status == 'confirmed' || status == 'completed')
      create_or_update_earning
    # Если статус изменился на cancelled или pending
    elsif (status_changed? || saved_change_to_status?) && 
          (status == 'cancelled' || status == 'pending')
      destroy_earning
    end
  end
  
  def create_or_update_earning
    return if earning.present?
    
    hotel = room&.hotel
    return unless hotel
    
    commission_rate = hotel.commission_rate.to_f
    commission_amount = calculate_commission
    return if commission_amount <= 0
    
    Earning.create!(
      booking_id: booking_id,
      hotel_id: hotel.hotel_id,
      amount: commission_amount,
      commission_rate: commission_rate,
      earned_at: Time.current
    )
    
    Rails.logger.info "Создан earning для брони ##{booking_id}: #{commission_amount}₽ (#{commission_rate}%)"
  rescue => e
    Rails.logger.error "Ошибка создания earning: #{e.message}"
  end
  
def destroy_earning
  if earning
    earning.destroy
    Rails.logger.info "Удален earning для брони ##{booking_id}"
  end
end
end