# typed: true

class Api::V1::PostsController < ApplicationController
  before_action :authenticate
  extend T::Sig

  sig { void }
  def index
    posts = Post.includes(:user, :likes).order(created_at: :desc).all
    render json: posts.map { |post| post_data(post) }, status: :ok
  end

  sig { void }
  def user_posts
    posts = Post.includes(:user, :likes).where(user_id: params[:user_id]).order(created_at: :desc)
    render json: posts.map { |post| post_data(post) }, status: :ok
  end

  sig { void }
  def following_posts
    # フォロー中のユーザーIDを取得
    following_ids = @current_user.following.pluck(:id)
    # フォロー中のユーザーと自分自身の投稿を取得
    posts = Post.includes(:user, :likes)
                .where(user_id: [following_ids, @current_user.id].flatten)
                .order(created_at: :desc)
    render json: posts.map { |post| post_data(post) }, status: :ok
  end

  sig { void }
  def show
    post = Post.includes(:user, :likes).find(params[:id])
    render json: post_data(post), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  sig { void }
  def create
    post = @current_user.posts.build(content: post_params[:content])
    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  sig { void }
  def update
    post = @current_user.posts.find_by(id: params[:id])

    if post
      if post.update(post_params)
        render json: post, status: :ok
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Post not found" }, status: :not_found
    end
  end

  sig { void }
  def destroy
    post = @current_user.posts.find_by(id: params[:id])

    if post
      post.destroy
      render json: { message: "Post deleted successfully" }, status: :ok
    else
      render json: { error: "Post not found" }, status: :not_found
    end
  end

  private

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def post_params
    params.require(:post).permit(:content).to_h
  end

  sig { params(post: Post).returns(T::Hash[Symbol, T.untyped]) }
  def post_data(post)
    {
      id: post.id,
      content: post.content,
      created_at: post.created_at,
      updated_at: post.updated_at,
      user: {
        id: post.user.id,
        name: post.user.name
      },
      likes_count: post.likes_count,
      liked_by_current_user: @current_user.liked?(post)
    }
  end
end
