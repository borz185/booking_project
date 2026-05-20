Rails.application.routes.draw do
  get "rooms/index"
  root "pages#home"
  
  # Регистрация
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"
  
  # Вход/выход
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Админка
  namespace :admin do
    root "admin#dashboard"
    
    resources :hotels do
      resources :rooms, only: [:index, :new, :create, :edit, :update, :destroy]
    end
    
    resources :bookings, only: [:index, :update, :destroy]
    resources :users, only: [:index, :show, :update, :destroy]
  end

  #Маршрут для номеров отеля
  resources :hotels, only: [] do
    resources :rooms, only: [:index], path: 'rooms'
  end
  
  # Бронирования
  resources :bookings, only: [:index, :show, :create] do
    member do
      post :cancel
    end
  end

  # Основные разделы
  get "hotels", to: "pages#hotels"
  get "favorites", to: "pages#favorites"
end