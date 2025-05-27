class ApplicationController < ActionController::API
  before_action :authenticate
  SECRET_KEY = Rails.application.credentials.secret_key_base

  def create_token(user_id)
    payload = {
      user_id: user_id,
      exp: (Time.now + 14.days).to_i,
      iat: Time.now.to_i,
      jti: SecureRandom.uuid
    }
    JWT.encode(payload, SECRET_KEY)
  end

  def decode_token(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
  end

  def authenticate
    authorization_header = request.headers[:authorization]
    if !authorization_header
      return render json: { error: "Authorization header missing" }, status: :unauthorized
    end

    token = authorization_header.split(" ")[1]
    if token.nil?
      return render json: { error: "Invalid authorization header format" }, status: :unauthorized
    end

    begin
      decoded_token = decode_token(token)
      @current_user = User.find(decoded_token[0]["user_id"])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
