Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "tournaments#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # get "/articles", to: "articles#index"
  # get "/articles/:id", to: "articles#show"
  resources :articles do
    resources :comments
  end

  resources :tournaments do
    resources :participants
    resources :target_faces
    resources :tournament_classes
  end
end
