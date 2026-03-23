class User < ApplicationRecord
  self.primary_key = 'user_id'
  
  # Валидации
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_hash, presence: true
  validates :phone, format: { with: /\+?[0-9\-\(\) ]+/, message: "неверный формат" }, allow_blank: true
  
  # ENUM для роли
  enum :role, { user: 'user', admin: 'admin' }, prefix: true
  
  # Связи
  has_many :bookings, foreign_key: 'user_id', primary_key: 'user_id', dependent: :destroy
  has_many :payments, through: :bookings
  
  # Методы
  def full_name
    username
  end
  
  def admin?
    role == 'admin'
  end
end