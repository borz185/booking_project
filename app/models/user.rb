class User < ApplicationRecord
  self.primary_key = 'user_id'
  
  has_secure_password
  
  before_save :downcase_email
  before_save :strip_whitespace

  # Username: 3-50 символов, только буквы, цифры, пробелы, подчёркивания
  validates :username, 
    presence: true, 
    length: { minimum: 3, maximum: 50 },
    format: { 
      with: /\A[a-zA-Zа-яА-Я0-9_\s]+\z/, 
      message: "может содержать только буквы, цифры, пробелы и подчёркивания" 
    }
  
  # Email: строгая валидация с проверкой домена
  validates :email, 
    presence: true, 
    uniqueness: { case_sensitive: false, message: "уже зарегистрирован" },
    format: { 
      with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, 
      message: "должен иметь корректный формат (example@domain.com)" 
    },
    length: { maximum: 255 }
  
  # Пароль: минимум 6 символов (has_secure_password требует)
  validates :password, 
    length: { minimum: 6, message: "должен быть не менее 6 символов" },
    allow_nil: true
  
  # Телефон: формат +7 или 8
  validates :phone, 
    format: { 
      with: /\A(\+7|8)?[\s\-]?\(?[489][0-9]{2}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}\z/, 
      message: "должен быть в формате +7 (999) 999-99-99" 
    },
    allow_blank: true
  
  enum :role, { user: 'user', admin: 'admin' }, prefix: true
  
  has_many :bookings, foreign_key: 'user_id', primary_key: 'user_id', dependent: :destroy
  has_many :payments, through: :bookings
  
  def full_name
    username.strip.titleize
  end
  
  def admin?
    role_admin?
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
  
  def strip_whitespace
    self.username = username.strip if username.present?
    self.email = email.strip if email.present?
    self.phone = phone.strip if phone.present?
  end
end