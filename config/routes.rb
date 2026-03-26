Rails.application.routes.draw do
  root "pages#home"
  
  # Регистрация
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"
  
  # Вход/выход
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  # Бронирования
    resources :bookings, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        post :cancel
      end
    end

  # Основные разделы
  get "hotels", to: "pages#hotels"
  get "favorites", to: "pages#favorites"
end