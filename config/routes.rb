Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :entrance_manifests, only: [:index, :show, :create, :update, :destroy]
      resources :departure_manifests, only: [:index, :show, :create, :update, :destroy]
      resources :shipments, only: [:index, :show, :create, :update, :destroy]
      resources :rooms, only: [:index, :show, :create, :update, :destroy]
      resources :worker_tasks, only: [:index, :show, :create, :update, :destroy]
      resources :technician_tasks, only: [:index, :show, :create, :update, :destroy]
      resources :sla_containers, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:destroy, :index]

      post 'users/sign_up', to: 'users#sign_up'
      post 'users/sign_in', to: 'users#sign_in'

      # Custom route for fetching worker tasks by room
      get 'worker_tasks/room/:room_id', to: 'worker_tasks#by_room'
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  # root "posts#index"
end

