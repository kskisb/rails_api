class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate, only: [ :login ]

  def login
    @user = User.find_by(email: login_params[:email])
    if @user&.authenticate(login_params[:password])
      @token = create_token(@user.id)
      render json: { user: @user, token: @token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
