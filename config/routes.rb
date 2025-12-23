Rails.application.routes.draw do
  get "auth/:provider/callback", to: "sessions#create"
  resource :session
  resources :passwords, param: :token
  root "tournaments#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :tournaments do
    get "/registrations/multiple_new", to: "registrations#multiple_new", as: :multiple_new_registrations
    post "/registrations/multiple", to: "registrations#multiple_create", as: :multiple_create_registrations
    resources :participants
    resources :registrations
    resources :target_faces
    resources :tournament_classes
    resources :groups
  end
end
