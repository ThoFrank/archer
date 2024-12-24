Rails.application.routes.draw do
  root "tournaments#index"

  # get "up" => "rails/health#show", as: :rails_health_check

  # get "/articles", to: "articles#index"
  # get "/articles/:id", to: "articles#show"
  resources :articles do
    resources :comments
  end

  resources :tournaments do
    resources :participants
  end
end
