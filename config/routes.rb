Rails.application.routes.draw do
  get "auth/:provider/callback", to: "sessions#create"
  resource :session
  resources :passwords, param: :token
  root "tournaments#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :tournaments do
    resources :participants, only: :index
    resources :registrations do
      get :multiple_new, on: :collection
      post :multiple_create, path: "multiple", on: :collection
    end
    resources :target_faces
    resources :tournament_classes do
      get :download, on: :collection
    end
    resources :groups
  end
end
