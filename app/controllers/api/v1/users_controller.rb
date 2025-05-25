# typed: true

class Api::V1::UsersController < ApplicationController
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
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  sig { void }
  def update
    user = User.find_by(id: params[:id])

    if user
      if user.update(user_params)
        render json: user, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  sig { void }
  def destroy
    user = User.find_by(id: params[:id])

    if user
      user.destroy
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
