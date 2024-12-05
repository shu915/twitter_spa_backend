# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        tweet = Tweet.find_by(id: params[:tweet_id])
        if tweet.nil?
          return render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        if tweet.bookmarks.exists?(user: current_api_v1_user)
          return render json: { error: '既にブックマーク済みです' }, status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          bookmark = tweet.bookmarks.create!(user: current_api_v1_user)
          render json: {
            my_bookmark_id: bookmark.id,
            bookmarks_count: tweet.reload.bookmarks_count
          }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end

      def destroy
        tweet = Tweet.find_by(id: params[:tweet_id])
        if tweet.nil?
          return render json: { error: 'ツイートが見つかりません' }, status: :not_found
        end

        bookmark = tweet.bookmarks.lock.find_by(user: current_api_v1_user)
        if bookmark.nil?
          return render json: { error: 'ブックマークが見つかりません' }, status: :not_found
        end

        ActiveRecord::Base.transaction do
          bookmark.destroy!
          render json: {
            my_bookmark_id: nil,
            bookmarks_count: tweet.reload.bookmarks_count
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
