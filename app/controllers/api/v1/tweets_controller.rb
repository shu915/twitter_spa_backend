# frozen_string_literal: true

module Api
  module V1
    class TweetsController < ApplicationController
      include TweetWithUserAndImage

      before_action :authenticate_api_v1_user!

      def index
        limit = params[:limit] || 20
        offset = params[:offset] || 0

        tweets, total_count = if params[:user_id]
                                case params[:tab]
                                when 'tweet'
                                  fetch_user_tweets_with_count(params[:user_id], limit, offset)
                                when 'reply'
                                  fetch_user_replies_with_count(params[:user_id], limit, offset)
                                when 'like'
                                  fetch_user_likes_with_count(params[:user_id], limit, offset)
                                end
                              elsif params[:is_following]
                                fetch_following_tweets_with_count(limit, offset)
                              elsif params[:is_bookmarks]
                                fetch_bookmarks_with_count(limit, offset)
                              else
                                fetch_all_tweets_with_count(limit, offset)
                              end

        tweets_with_info = tweets_with_info(tweets)

        render json: {
          tweets: tweets_with_info,
          total_count:
        }, status: :ok
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

        render json: {
          tweet: tweet_with_user_and_image_url(tweet),
          ancestors: ancestors.map { |ancestor| tweet_with_user_and_image_url(ancestor) },
          replies: replies.map { |reply| tweet_with_user_and_image_url(reply) }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'ツイートが見つかりません' }, status: :not_found
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
        tweets = Tweet.includes(:retweets, user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .joins('LEFT JOIN (SELECT tweet_id, MAX(created_at) AS latest_retweet_date FROM retweets GROUP BY tweet_id) latest_retweets ON tweets.id = latest_retweets.tweet_id')
                      .select('tweets.*, COALESCE(latest_retweets.latest_retweet_date, tweets.created_at) AS sort_date')
                      .order('sort_date DESC')
                      .offset(offset)
                      .limit(limit)

        total_count = Tweet.count

        [tweets, total_count]
      end

      def fetch_user_tweets_with_count(user_id, limit, offset)
        tweets = Tweet.includes(:retweets, user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .left_joins(:retweets)
                      .where(tweets: { user_id: }).or(Tweet.where(retweets: { user_id: }))
                      .select('tweets.*, COALESCE(retweets.created_at, tweets.created_at) AS sort_date')
                      .order('sort_date DESC')
                      .offset(offset)
                      .limit(limit)

        total_count = Tweet.left_joins(:retweets)
                           .where('tweets.user_id = :user_id OR retweets.user_id = :user_id', user_id:).distinct
                           .count
        [tweets, total_count]
      end

      def fetch_user_replies_with_count(user_id, limit, offset)
        tweets = Tweet.includes(:retweets, user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .where(user_id:)
                      .joins(:replies_as_child)
                      .order(created_at: :desc).offset(offset).limit(limit)
        total_count = Tweet.where(user_id:).joins(:replies_as_child).count
        [tweets, total_count]
      end

      def fetch_user_likes_with_count(user_id, limit, offset)
        tweets = Tweet.includes(:likes, user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .joins(:likes)
                      .where(likes: { user_id: })
                      .order(created_at: :desc)
                      .offset(offset)
                      .limit(limit)
        total_count = Tweet.where(likes: { user_id: }).joins(:likes).count
        [tweets, total_count]
      end

      def fetch_following_tweets_with_count(limit, offset)
        following_user_ids = current_api_v1_user.active_follows.pluck(:following_id)
        tweets = Tweet.includes(user: [profile_image_attachment: :blob], image: [file_attachment: :blob])
                      .where(user_id: following_user_ids)
                      .order(created_at: :desc)
                      .offset(offset)
                      .limit(limit)
        total_count = Tweet.where(user_id: following_user_ids).count
        [tweets, total_count]
      end

      def fetch_bookmarks_with_count(limit, offset)
        base_query = Tweet.joins(:bookmarks)
                          .where(bookmarks: { user_id: current_api_v1_user.id })
                          .includes(:retweets, :likes, :bookmarks, user: [profile_image_attachment: :blob], image: [file_attachment: :blob])

        tweets = base_query.order(created_at: :desc)
                           .offset(offset)
                           .limit(limit)

        total_count = base_query.count
        [tweets, total_count]
      end

      # ツイートにリツイートやイイネの情報を含める
      def tweets_with_info(tweets)
        tweet_ids = tweets.map(&:id)
        retweets = Retweet.where(tweet_id: tweet_ids, user: current_api_v1_user).index_by(&:tweet_id)
        likes = Like.where(tweet_id: tweet_ids, user: current_api_v1_user).index_by(&:tweet_id)
        bookmarks = Bookmark.where(tweet_id: tweet_ids, user: current_api_v1_user).index_by(&:tweet_id)
        tweets.map do |tweet|
          tweet_with_user_and_image_url(tweet)
            .merge(my_retweet_id: retweets[tweet.id]&.id, my_like_id: likes[tweet.id]&.id, my_bookmark_id: bookmarks[tweet.id]&.id)
        end
      end
    end
  end
end
