# frozen_string_literal: true

module Api
  module V1
    class LikesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        tweet = Tweet.find(params[:tweet_id])
        if tweet.nil?
          return render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        if tweet.likes.exists?(user: current_api_v1_user)
          return render json: { error: '既にいいね済みです' }, status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          like = tweet.likes.create!(user: current_api_v1_user)
          render json: {
            my_like_id: like.id,
            likes_count: tweet.reload.likes_count
          }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end

      def destroy
        tweet = Tweet.find(params[:tweet_id])
        if tweet.nil?
          return render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        like = tweet.likes.lock.find_by(user: current_api_v1_user)
        if like.nil?
          return render json: { error: 'いいねが見つかりません' }, status: :not_found
        end

        ActiveRecord::Base.transaction do
          like.destroy!
          render json: {
            my_like_id: nil,
            likes_count: tweet.reload.likes_count
          }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end
    end
  end
end
