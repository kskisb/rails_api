class Api::V1::UsersController < ApplicationController
  def index
    users = User.all

    if users
      render json: users, status: :ok
    else
      render json: { error: "Users not found" }, status: :not_found
    end
  end

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

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

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
