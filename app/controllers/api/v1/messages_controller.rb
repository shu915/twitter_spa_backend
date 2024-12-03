# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      def index
        messages = Message.where(group_id: params[:group_id])
        render json: messages
      end
    end
  end
end
