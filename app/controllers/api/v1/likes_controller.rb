# frozen_string_literal: true

module Api
  module V1
    class LikesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        tweet = Tweet.find_by(id: params[:tweet_id])
        if tweet.nil?
          render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        if tweet.likes.exists?(user: current_api_v1_user)
          render json: { error: '既にいいね済みです' }, status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          like = tweet.likes.create!(user: current_api_v1_user)
          render json: {
            my_like_id: like.id,
            likes_count: tweet.reload.likes_count
          }, status: :ok
        end
      end

      def destroy
        tweet = Tweet.find_by(id: params[:tweet_id])
        if tweet.nil?
          render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        like = tweet.likes.find_by(user: current_api_v1_user)
        if like.nil?
          render json: { error: 'いいねが見つかりません' }, status: :not_found
        end

        ActiveRecord::Base.transaction do
          like.destroy!
          render json: {
            my_like_id: nil,
            likes_count: tweet.reload.likes_count
          }, status: :ok
        end
      end
    end
  end
end
