Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "tournaments#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :tournaments do
    get "/participants/multiple_new", to: "participants#multiple_new", as: :multiple_new_participants
    post "/participants/multiple", to: "participants#multiple_create", as: :multiple_create_participants
    resources :participants
    resources :target_faces
    resources :tournament_classes
    resources :groups
  end
end
