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

  # Личный кабинет (сингулярный ресурс, так как привязан к current_user)
  resource :profile, only: [:show, :edit, :update], controller: 'profiles'

  post '/subscribe', to: 'subscriptions#create', as: 'subscribe'

  # Админка
  namespace :admin do
    root "admin#dashboard"
    
    resources :hotels do
      resources :rooms, only: [:index, :new, :create, :edit, :update, :destroy] do 

      end
    end
    
    resources :bookings, only: [:index, :update] do 
      member do
        patch :update_status
      end
    end

    # resources :bookings, only: [:index, :update, :destroy] do 
      # member do
        # patch :update_status
      # end
    # end

    resources :earnings, only: [:index]

    resources :users, only: [:index, :show, :update, :destroy]

    post 'newsletters/send', to: 'newsletters#send_message'
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