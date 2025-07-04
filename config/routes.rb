Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      get "users/me", to: "users#me"

      get "users/:user_id/posts", to: "posts#user_posts"
      resources :users, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          get "following", to: "relationships#following"
          get "followers", to: "relationships#followers"
        end

        get "likes", to: "likes#liked_posts"
      end

      resources :posts, only: [ :index, :show, :create, :update, :destroy ] do
        collection do
          get "following", to: "posts#following_posts"
        end
        post "like", to: "likes#create"
        delete "like", to: "likes#destroy"
        get "liked_users", to: "likes#liked_users"
      end
      resources :relationships, only: [ :create, :destroy ] do
        collection do
          get "check/:user_id", to: "relationships#check"
        end
      end

      resources :conversations, only: [ :index, :show, :create ] do
        resources :messages, only: [ :create ]
      end
    end
  end
end
