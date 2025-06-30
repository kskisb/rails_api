class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    # 会話の参加者かどうかを確認
    if conversation.sender_id == current_user.id || conversation.recipient_id == current_user.id
      stream_for conversation
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
