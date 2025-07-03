Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 本番環境では特定のドメインのみを許可する
    origins ENV["ALLOWED_ORIGINS"]&.split(",") || "http://localhost:5173"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: false
  end
end
