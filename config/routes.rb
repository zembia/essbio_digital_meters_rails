Rails.application.routes.draw do
  resources :meters, only: [:index, :show]
  resources :notifications, only: [:index, :show]
  #get "meters/index"
  #get "meters/show"
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root 'pages#index'
  get 'pages/index'

  get 'uploaded_file/index', to: 'uploaded_files#index'
  post 'uploaded_file/upload_files', to: 'uploaded_files#upload_files', as: 'upload_files'

end
