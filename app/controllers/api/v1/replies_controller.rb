# frozen_string_literal: true

module Api
  module V1
    class RepliesController < ApplicationController
      include TweetWithUserAndImage

      before_action :authenticate_api_v1_user!

      def index
        selected_tweet = Tweet.find(params[:tweet_id])
        ancestors = fetch_ancestor_tweet(selected_tweet)
        children = fetch_children_tweets(selected_tweet)
        render json: { ancestors: ancestors.map { |tweet| tweet_with_user_and_image_url(tweet) },
                       children: children.map { |tweet| tweet_with_user_and_image_url(tweet) } }
      end

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

      def fetch_ancestor_tweet(tweet)
        ancestors = []

        while tweet.parent
          ancestors.unshift(tweet.parent)
          tweet = tweet.parent
        end
        ancestors
      end

      def fetch_children_tweets(tweet)
        tweet.children
      end
    end
  end
end
