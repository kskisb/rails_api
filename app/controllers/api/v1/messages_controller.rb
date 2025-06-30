class Api::V1::MessagesController < ApplicationController
  before_action :authenticate
  before_action :set_conversation
  before_action :check_conversation_participant
  extend T::Sig

  sig { void }
  def create
    message = @conversation.messages.new(message_params)
    message.user = @current_user

    if message.save
      message_data = {
        id: message.id,
        body: message.body,
        created_at: message.created_at,
        user_id: message.user_id,
        read: message.read,
        user_name: @current_user.name
      }

      # WebSocketで通知
      ConversationChannel.broadcast_to(
        @conversation,
        message_data
      )

      render json: message_data, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  sig { void }
  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Conversation not found" }, status: :not_found
  end

  sig { void }
  def check_conversation_participant
    unless @conversation.sender_id == @current_user.id || @conversation.recipient_id == @current_user.id
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end

  # sig { returns(T::Hash[Symbol, T.untyped]) }
  def message_params
    params.require(:message).permit(:body)
  end
end
