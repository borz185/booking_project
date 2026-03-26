class User < ApplicationRecord
  self.primary_key = 'user_id'
  
  has_secure_password
  
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :phone, format: { with: /\+?[0-9\-\(\) ]+/, message: "неверный формат" }, allow_blank: true
  
  enum :role, { user: 'user', admin: 'admin' }, prefix: true
  
  has_many :bookings, foreign_key: 'user_id', primary_key: 'user_id', dependent: :destroy
  has_many :payments, through: :bookings
  
  def full_name
    username
  end
  
  def admin?
    role_admin?
  end
end