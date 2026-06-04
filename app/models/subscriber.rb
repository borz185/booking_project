class Subscriber < ApplicationRecord
  # Строгая валидация email
  validates :email, 
            presence: { message: "не может быть пустым" },
            uniqueness: { case_sensitive: false, message: "уже подписан на рассылку" },
            format: { 
              with: /\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z/,
              message: "должен быть в формате example@mail.com"
            }
end