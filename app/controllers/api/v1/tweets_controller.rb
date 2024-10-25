# frozen_string_literal: true

module Api
  module V1
    class TweetsController < ApplicationController
      before_action :authenticate_api_v1_user!
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

      def index
        tweets = Tweet.all.order(created_at: :desc)
        render json: { tweets: }, status: :ok
      end

      def create
        tweet = current_api_v1_user.tweets.new(tweet_params)
        if tweet.save!
          render json: { tweet_id: tweet.id }, status: :created
        else
          render json: { message: 'ツイートの保存に失敗しました', errors: tweet.errors.messages }, status: :unprocessable_entity
        end
      end

      private

      def tweet_params
        params.require(:tweet).permit(:content, :image_url)
      end

      def render_unprocessable_entity_response(exception)
        render json: { message: 'ツイートの保存に失敗しました', errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
