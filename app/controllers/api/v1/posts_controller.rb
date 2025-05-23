# typed: true

class Api::V1::PostsController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    posts = Post.all
    render json: posts
  end

  sig { void }
  def user_posts
    posts = Post.where(user_id: params[:user_id])
    render json: posts
  end

  sig { void }
  def show
    @post = Post.find(params[:id])
    render json: @post
  rescue ActiveRecord::RecordNotFound
    render json: { error: '投稿が見つかりません' }, status: :not_found
  end
end
