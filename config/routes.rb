Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: [ :index, :show, :create, :update, :destroy ]
      resources :posts, only: [ :index, :show, :create, :update, :destroy ]
      get "users/:user_id/posts", to: "posts#user_posts"
    end
  end
end
