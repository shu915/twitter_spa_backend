# frozen_string_literal: true

module Api
  module V1
    class RepliesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        parent_tweet = Tweet.find(params[:tweet_id])
        child_tweet = parent_tweet.children.build(reply_params)

        if child_tweet.save
          render json: { tweet_id: child_tweet.id }, status: :created
        else
          render json: { message: '返信の保存に失敗しました', errors: child_tweet.errors.messages }, status: :unprocessable_entity
        end
      end

      private

      def reply_params
        params.require(:reply).permit(:content).merge(user_id: current_api_v1_user.id)
      end
    end
  end
end
