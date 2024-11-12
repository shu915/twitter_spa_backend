# frozen_string_literal: true

module Api
  module V1
    class TweetsController < ApplicationController
      include TweetWithUserAndImage

      before_action :authenticate_api_v1_user!

      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0

        if params[:user_id]
          tweets, total_count = fetch_user_tweets_with_count(params[:user_id], limit, offset)
        else
          tweets, total_count = fetch_all_tweets_with_count(limit, offset)
        end

        render json: { tweets: tweets.map { |tweet| tweet_with_user_and_image_url(tweet) },
                       total_count: }, status: :ok
      end

      def show
        tweet = Tweet.includes(user: [profile_image_attachment: :blob], image: [file_attachment: :blob]).find(params[:id])
        ancestors = Tweet.includes(
          user: { profile_image_attachment: :blob },
          image: { file_attachment: :blob }
        ).where(id: tweet.ancestor_ids)

        replies = Tweet.includes(
          user: { profile_image_attachment: :blob },
          image: { file_attachment: :blob }
        ).where(id: tweet.child_ids)

        if tweet
          render json: {
            tweet: tweet_with_user_and_image_url(tweet),
            ancestors: ancestors.map { |ancestor| tweet_with_user_and_image_url(ancestor) },
            replies: replies.map { |reply| tweet_with_user_and_image_url(reply) }
          }, status: :ok
        else
          render json: { message: 'ツイートが見つかりません' }, status: :not_found
        end
      end

      def create
        tweet = current_api_v1_user.tweets.new(tweet_params)
        if tweet.save
          render json: { tweet_id: tweet.id }, status: :created
        else
          render json: { message: 'ツイートの保存に失敗しました', errors: tweet.errors.messages }, status: :unprocessable_entity
        end
      end

      def destroy
        ActiveRecord::Base.transaction do
          tweet = Tweet.find(params[:id])

          render json: { message: 'ツイートの削除に失敗しました' }, status: :unauthorized if current_api_v1_user.id != tweet.user_id

          tweet.destroy!
          render json: { message: 'ツイートを削除しました' }, status: :ok
        rescue StandardError
          render json: { message: 'ツイートの削除に失敗しました' }, status: :unprocessable_entity
        end
      end

      private

      def tweet_params
        params.require(:tweet).permit(:content, :image_url)
      end

      def fetch_all_tweets_with_count(limit, offset)
        tweets = Tweet.includes(user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .order(created_at: :desc).offset(offset).limit(limit)
        total_count = Tweet.count
        [tweets, total_count]
      end

      def fetch_user_tweets_with_count(user_id, limit, offset)
        tweets = Tweet.includes(user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .where(user_id:)
                      .order(created_at: :desc).offset(offset).limit(limit)
        total_count = Tweet.where(user_id:).count
        [tweets, total_count]
      end
    end
  end
end
