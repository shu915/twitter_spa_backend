# frozen_string_literal: true

module Api
  module V1
    class RetweetsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        tweet = Tweet.find(params[:tweet_id])
        if tweet.retweets.find_by(user: current_api_v1_user)
          render json: { my_retweet_id: tweet.retweets.find_by(user: current_api_v1_user).id, retweets_count: tweet.retweets_count }, status: :ok
        else
          render json: { my_retweet_id: nil, retweets_count: tweet.retweets_count }, status: :ok
        end
      end

      def create
        tweet = Tweet.find(params[:tweet_id])
        tweet.retweets.create(user: current_api_v1_user)
        render json: { my_retweet_id: tweet.retweets.find_by(user: current_api_v1_user).id, retweets_count: tweet.retweets_count }, status: :created
      end

      def destroy
        tweet = Tweet.find(params[:tweet_id])
        tweet.retweets.find_by(user: current_api_v1_user).destroy
        render json: { my_retweet_id: nil, retweets_count: tweet.retweets_count }, status: :ok
      end
    end
  end
end
