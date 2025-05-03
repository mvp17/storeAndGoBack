Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :entrance_manifests, only:[:index, :show, :create, :update, :destroy]
      resources :departure_manifests, only: [:index, :show, :create, :update, :destroy]
      resources :shipments, only: [:index, :show, :create, :update, :destroy]
      resources :rooms, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch 'open'
          patch 'close'
        end
      end
      resources :worker_tasks, only: [:index, :show, :create, :update, :destroy]
      resources :technician_tasks, only: [:index, :show, :create, :update, :destroy]
      resources :sla_containers, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:destroy, :index]

      post 'users/sign_up', to: 'users#sign_up'
      post 'users/sign_in', to: 'users#sign_in'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
