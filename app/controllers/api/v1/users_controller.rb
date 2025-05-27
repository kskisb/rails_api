# typed: true

class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: [ :me, :update, :destroy ]
  extend T::Sig

  sig { void }
  def index
    users = User.all

    if users.any?
      render json: users, status: :ok
    else
      render json: { error: "Users not found" }, status: :not_found
    end
  end

  sig { void }
  def show
    user = User.find_by(id: params[:id])

    if user
      render json: user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  sig { void }
  def create
    user = User.new(user_params)

    if user.save
      @token = create_token(user.id)
      render json: { user: user, token: @token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  sig { void }
  def me
    render json: @current_user, status: :ok
  end

  sig { void }
  def update
    if @current_user
      if @current_user.update(user_params)
        render json: @current_user, status: :ok
      else
        render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  sig { void }
  def destroy
    if @current_user
      @current_user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  private

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def user_params
    params.require(:user).permit(:name, :email, :password).to_h
  end
end
