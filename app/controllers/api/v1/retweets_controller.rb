# frozen_string_literal: true

module Api
  module V1
    class RetweetsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        tweet = Tweet.find_by(id: params[:tweet_id])
        return render json: { error: 'ツイートが見つかりません' }, status: :not_found unless tweet

        return render json: { error: '既にリツイート済みです' }, status: :unprocessable_entity if tweet.retweets.exists?(user: current_api_v1_user)

        ActiveRecord::Base.transaction do
          retweet = tweet.retweets.create!(user: current_api_v1_user)
          render json: {
            my_retweet_id: retweet.id,
            retweets_count: tweet.reload.retweets_count
          }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def destroy
        tweet = Tweet.find_by(id: params[:tweet_id])
        return render json: { error: 'ツイートが見つかりません' }, status: :not_found unless tweet

        retweet = tweet.retweets.find_by(user: current_api_v1_user)
        return render json: { error: 'リツイートが見つかりません' }, status: :not_found unless retweet

        ActiveRecord::Base.transaction do
          retweet.destroy!
          render json: {
            my_retweet_id: nil,
            retweets_count: tweet.reload.retweets_count
          }, status: :ok
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
