# typed: true

class Api::V1::RelationshipsController < ApplicationController
  before_action :authenticate
  extend T::Sig

  sig { void }
  def create
    user = User.find(params[:followed_id])

    if user == @current_user
      render json: { error: "Cannot follow yourself" }, status: :unprocessable_entity
      return
    end

    if @current_user.following?(user)
      render json: { error: "Already following this user" }, status: :unprocessable_entity
      return
    end

    relationship = @current_user.follow(user)
    render json: {
      message: "Successfully followed user",
      user: user,
      relationshipId: relationship.id
    }, status: :created
  end

  sig { void }
  def destroy
    # relationshipのIDまたはfollowed_idのどちらかで関係を検索
    relationship = if params[:id].present?
      Relationship.find_by(id: params[:id])
    elsif params[:followed_id].present?
      @current_user.active_relationships.find_by(followed_id: params[:followed_id])
    end

    user = relationship&.followed

    if user.nil?
      render json: { error: "Relationship not found" }, status: :not_found
      return
    end

    @current_user.unfollow(user)
    render json: { message: "Successfully unfollowed user" }, status: :ok
  end

  sig { void }
  def check
    user = User.find(params[:user_id])

    if @current_user.following?(user)
      relationship = @current_user.active_relationships.find_by(followed_id: user.id)
      render json: { isFollowing: true, relationshipId: relationship.id }, status: :ok
    else
      render json: { isFollowing: false }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  sig { void }
  def following
    user = User.find_by(id: params[:id])
    following = T.must(user).following

    render json: following, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  sig { void }
  def followers
    user = User.find_by(id: params[:id])
    followers = T.must(user).followers

    render json: followers, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end
end
