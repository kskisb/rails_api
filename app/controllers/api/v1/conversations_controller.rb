# typed: true

class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate
  extend T::Sig

  sig { void }
  def index
    conversations = @current_user.conversations.includes(:sender, :recipient, messages: :user)

    conversations_data = conversations.map do |conversation|
      other_user = conversation.sender_id == @current_user.id ? conversation.recipient : conversation.sender
      {
        id: conversation.id,
        other_user: {
          id: other_user.id,
          name: other_user.name
        },
        last_message: conversation.messages.order(created_at: :desc).first&.body,
        unread_count: conversation.messages.unread.where.not(user_id: @current_user.id).count,
        updated_at: conversation.messages.maximum(:created_at) || conversation.updated_at
      }
    end

    conversations_sorted = conversations_data.sort_by { |c| c[:updated_at] }.reverse

    render json: conversations_sorted, status: :ok
  end

  sig { void }
  def show
    conversation = Conversation.find(params[:id])

    # 会話の参加者でない場合はアクセス不可
    unless conversation.sender_id == @current_user.id || conversation.recipient_id == @current_user.id
      return render json: { error: "Unauthorized" }, status: :forbidden
    end

    # 相手のユーザー情報を取得
    other_user = conversation.sender_id == @current_user.id ? conversation.recipient : conversation.sender

    # 未読メッセージを既読に更新
    conversation.messages.unread.where.not(user_id: @current_user.id).update_all(read: true)

    render json: {
      id: conversation.id,
      other_user: {
        id: T.must(other_user).id,
        name: T.must(other_user).name
      },
      messages: conversation.messages.includes(:user).order(created_at: :asc).map do |message|
        {
          id: message.id,
          body: message.body,
          created_at: message.created_at,
          user_id: message.user_id,
          read: message.read,
          user_name: T.must(message.user).name
        }
      end
    }, status: :ok
  end

  sig { void }
  def create
    other_user = User.find(params[:recipient_id])

    # 自分自身にはDMを送れない
    if other_user.id == @current_user.id
      return render json: { error: "Cannot message yourself" }, status: :unprocessable_entity
    end

    # 既存の会話を検索、なければ新規作成
    conversation = Conversation.find_between(@current_user.id, other_user.id)

    if conversation.nil?
      conversation = Conversation.create!(
        sender_id: @current_user.id,
        recipient_id: other_user.id
      )
    end

    render json: { conversation_id: conversation.id }, status: :created
  end
end
