class Payment < ApplicationRecord
  self.primary_key = 'payment_id'
  
  # Валидации
  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :booking_id, presence: true
  
  # ENUM для статуса и метода
  enum :payment_status, { pending: 'pending', paid: 'paid', failed: 'failed', refunded: 'refunded' }, prefix: true
  enum :payment_method, { card: 'card', cash: 'cash' }, prefix: true
  
  # Связи
  belongs_to :booking, foreign_key: 'booking_id', primary_key: 'booking_id'
  
  # Методы
  def paid?
    payment_status == 'paid'
  end
  
  def mark_as_paid!
    update(payment_status: 'paid', paid_at: Time.current)
  end
end