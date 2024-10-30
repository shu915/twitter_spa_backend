# frozen_string_literal: true

module Api
  module V1
    class ImagesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        # 画像ファイルを受け取り、Active Storageで保存
        tweet = Tweet.find(image_params[:tweet_id])
        image = tweet.build_image(file: image_params[:image])

        if image.save
          # 保存後に画像のURLを返す
          render json: {}, status: :created
        else
          render json: { errors: image.errors.messages }, status: :unprocessable_entity
        end
      end

      private

      def image_params
        params.require(:image).permit(:tweet_id, :image)
      end
    end
  end
end
