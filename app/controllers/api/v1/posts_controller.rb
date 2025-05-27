# typed: true

class Api::V1::PostsController < ApplicationController
  before_action :authenticate, only: [ :create, :update, :destroy ]
  extend T::Sig

  sig { void }
  def index
    posts = Post.all
    render json: posts, status: :ok
  end

  sig { void }
  def user_posts
    posts = Post.where(user_id: params[:user_id])
    render json: posts, status: :ok
  end

  sig { void }
  def show
    post = Post.find(params[:id])
    render json: post
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
end
