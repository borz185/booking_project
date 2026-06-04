class Earning < ApplicationRecord
  # Явно указываем foreign_key и primary_key
  belongs_to :booking, foreign_key: :booking_id, primary_key: :booking_id
  belongs_to :hotel, foreign_key: :hotel_id, primary_key: :hotel_id
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :commission_rate, presence: true
  
  # Скоупы для фильтрации по периодам
  scope :today, -> { where("earned_at >= ?", Date.current.beginning_of_day) }
  scope :this_month, -> { where("earned_at >= ?", Date.current.beginning_of_month) }
  scope :this_year, -> { where("earned_at >= ?", Date.current.beginning_of_year) }
  
  # Методы для подсчета
  def self.total_today
    today.sum(:amount)
  end
  
  def self.total_this_month
    this_month.sum(:amount)
  end
  
  def self.total_this_year
    this_year.sum(:amount)
  end
  
  def self.total_all_time
    sum(:amount)
  end
end