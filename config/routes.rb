Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  resources :users, only: [:new, :create]
  get  "/onboarding/experience", to: "onboarding#experience", as: :onboarding_experience
  post "/onboarding/experience", to: "onboarding#update"
  resources :lessons, only: [:show]
  resources :exercises, only: [:show] do
    post :submit, on: :member
  end
  resources :sessions, only: [:new, :create] do
    get :summary, on: :member
  end
  resources :curriculum, only: [:index]
  get "/dashboard", to: "dashboard#index", as: :dashboard
end
