Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      get "users/me", to: "users#me"

      get "users/:user_id/posts", to: "posts#user_posts"
      resources :users, only: [ :index, :show, :create, :update, :destroy ]
      resources :posts, only: [ :index, :show, :create, :update, :destroy ]
    end
  end
end
