# typed: true

class Api::V1::LikesController < ApplicationController
  before_action :authenticate
  before_action :set_post, only: [ :create, :destroy ]
  extend T::Sig

  sig { void }
  def create
    if @current_user.liked?(@post)
      render json: { error: "You've already liked this post" }, status: :unprocessable_entity
      return
    end

    @like = Like.new(user: @current_user, post: @post)

    if @like.save
      render json: {
        message: "Post liked successfully",
        like_id: @like.id,
        likes_count: @post.reload.likes_count
      }, status: :created
    else
      render json: { errors: @like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  sig { void }
  def destroy
    @like = @current_user.likes.find_by(post: @post)

    if @like
      @like.destroy
      render json: {
        message: "Like removed successfully",
        likes_count: @post.reload.likes_count
      }, status: :ok
    else
      render json: { error: "Like not found" }, status: :not_found
    end
  end

  sig { void }
  def liked_users
    post = Post.find(params[:post_id])
    users = post.liked_users

    render json: users, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  sig { void }
  def liked_posts
    user = User.find(params[:user_id])

    posts = Post.joins(:likes)
                .where(likes: { user_id: user.id })
                .includes(:user)
                .order('likes.created_at DESC')

    post_like_counts = Like.where(post_id: posts.map(&:id)).group(:post_id).count
    current_user_liked_post_ids = @current_user ? Set.new(@current_user.likes.pluck(:post_id)) : Set.new

    posts_json = posts.map do |post|
      post.as_json(include: { user: { only: [:id, :name] } })
        .merge({
          likes_count: post_like_counts[post.id] || 0,
          liked_by_current_user: current_user_liked_post_ids.include?(post.id)
        })
    end

    render json: posts_json, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  private

  sig { void }
  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end
end
