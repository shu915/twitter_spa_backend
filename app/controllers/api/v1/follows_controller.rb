# frozen_string_literal: true

module Api
  module V1
    class FollowsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        target_user = User.find(params[:user_id])
        # params[:is_followings]は文字列として渡される
        users = if params[:is_followings] == 'true'
                  target_user.followings
                else
                  target_user.followers
                end
        render json: users.map { |u|
          u.as_json(only: %i[id account_name display_name bio])
           .merge(
             profile_image_url: u.profile_image_url,
             following: current_api_v1_user.active_follows.exists?(following: u) # フォローしているかどうかを確認
           )
        }, status: :ok
      end

      def create
        user = User.find(params[:user_id])
        new_follow = current_api_v1_user.active_follows.create(following: user)
        render json: { following_id: new_follow.id }, status: :created
      end

      def destroy
        user = User.find(params[:user_id])
        current_api_v1_user.active_follows.find_by(following: user).destroy
        render json: { following_id: nil }, status: :no_content
      end
    end
  end
end
