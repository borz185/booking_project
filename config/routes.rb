Rails.application.routes.draw do
  get "auth/signup"
  get "auth/login"
  root "pages#home"
  
  # Аутентификация
  get "signup", to: "auth#signup"
  post "signup", to: "auth#register"
  get "login", to: "auth#login"
  post "login", to: "auth#authenticate"
  get "logout", to: "auth#logout"
  
  # Основные разделы
  get "hotels", to: "pages#hotels"
  get "favorites", to: "pages#favorites"
end
