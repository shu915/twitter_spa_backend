# frozen_string_literal: true

module Api
  module V1
    class ImagesController < ApplicationController
      before_action :authenticate_api_v1_user!
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

      def create
        # 画像ファイルを受け取り、Active Storageで保存
        tweet = Tweet.find(params[:image][:tweet_id])
        image = tweet.images.build(file: params[:image][:image])

        if image.save!
          # 保存後に画像のURLを返す
          render json: {}, status: :created
        else
          render json: { error: '画像の保存に失敗しました' }, status: :unprocessable_entity
        end
      end

      private

      def image_params
        params.require(:image).permit(:tweet_id, :image)
      end

      def render_unprocessable_entity_response(exception)
        render json: { message: '画像の保存に失敗しました', errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
