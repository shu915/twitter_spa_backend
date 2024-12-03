# frozen_string_literal: true

class GroupChannel < ApplicationCable::Channel
  def subscribed
    stream_from "group_#{params[:group_id]}"
  end

  def unsubscribed
    stop_all_streams
  end

  def speak(data)
    message = Message.new(
      content: data['message'],
      group_id: params[:group_id],
      user_id: current_user.id
    )

    if message.save
      ActionCable.server.broadcast(
        "group_#{params[:group_id]}",
        {
          message:,
          user: current_user.display_name,
          created_at: message.created_at.strftime('%H:%M')
        }
      )
    else
      ActionCable.server.broadcast(
        "group_#{params[:group_id]}",
        { error: message.errors.full_messages }
      )
    end
  end
end
