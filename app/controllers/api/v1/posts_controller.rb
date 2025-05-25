# typed: true

class Api::V1::PostsController < ApplicationController
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
    user = User.find_by(id: params[:user_id])

    if user
      post = user.posts.build(content: post_params[:content])
      if post.save
        render json: post, status: :created
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  sig { void }
  def update
    post = Post.find_by(id: params[:id])

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
    post = Post.find_by(id: params[:id])

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
    params.require(:post).permit(:content, :user_id).to_h
  end
end
