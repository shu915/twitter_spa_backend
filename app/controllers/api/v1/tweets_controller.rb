# frozen_string_literal: true

module Api
  module V1
    class TweetsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0

        tweets = Tweet.includes(user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .order(created_at: :desc).offset(offset).limit(limit)

        total_count = Tweet.count

        render json: { tweets: tweets.map do |tweet|
                                 tweet.as_json(include: { user: { only: %i[id display_name account_name] } })
                                      .merge(
                                        image_url: tweet.image&.file&.attached? ? url_for(tweet.image.file) : nil,
                                        user_profile_image_url: tweet.user.profile_image.attached? ? url_for(tweet.user.profile_image) : nil
                                      )
                               end,
                       total_count: }, status: :ok
      end

      def show
        tweet = Tweet.find(params[:id])
        render json: tweet.as_json(include: { user: { only: %i[id display_name account_name] } })
                          .merge(
                            image_url: tweet.image&.file&.attached? ? url_for(tweet.image.file) : nil,
                            user_profile_image_url: tweet.user.profile_image.attached? ? url_for(tweet.user.profile_image) : nil
                          ), status: :ok
      end

      def create
        tweet = current_api_v1_user.tweets.new(tweet_params)
        if tweet.save
          render json: { tweet_id: tweet.id }, status: :created
        else
          render json: { message: 'ツイートの保存に失敗しました', errors: tweet.errors.messages }, status: :unprocessable_entity
        end
      end

      private

      def tweet_params
        params.require(:tweet).permit(:content, :image_url)
      end
    end
  end
end
