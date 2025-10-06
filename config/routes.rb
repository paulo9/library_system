Rails.application.routes.draw do
  devise_for :users
  
  # Public routes (no authentication required)
  get 'pages/home'
  root "pages#home"
  
  # Protected routes (authentication required)
  resources :books do
    member do
      post :borrow_book
    end
  end
  
  resources :loans, only: [:index, :show] do
    member do
      patch :return_book
    end
  end
  
  # Dashboard routes
  get 'dashboard', to: 'dashboard#show'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
