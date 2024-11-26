# frozen_string_literal: true

module Api
  module V1
    class FollowsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        target_user = User.find(params[:user_id])
        # params[:is_followings]は文字列として渡される
        is_followings = ActiveModel::Type::Boolean.new.cast(params[:is_followings])
        users = if is_followings
                  target_user.followings.includes(profile_image_attachment: :blob)
                else
                  target_user.followers.includes(profile_image_attachment: :blob)
                end
        following_ids = current_api_v1_user.active_follows
                                            .where(following: users)
                                            .pluck(:following_id)
                                            .to_set
        render json: users.map { |u|
          u.as_json(only: %i[id account_name display_name bio])
           .merge(
             profile_image_url: u.profile_image_url,
             you_are_following: following_ids.include?(u.id)
           )
        }, status: :ok
      end

      def create
        user = User.find(params[:user_id])

        if user.id == current_api_v1_user.id
          render json: { error: '自分自身をフォローすることはできません' }, 
                 status: :unprocessable_entity
          return
        end

        if current_api_v1_user.active_follows.exists?(following: user)
          render json: { error: '既にフォロー済みです' }, 
                 status: :unprocessable_entity
          return
        end
        new_follow = current_api_v1_user.active_follows.create(following: user)
        render json: { following_id: new_follow.id }, status: :created
      end

      def destroy
        user = User.find(params[:user_id])
        follow = current_api_v1_user.active_follows.find_by(following: user)

        if follow.nil?
          render json: { error: 'フォロー関係が存在しません' }, 
                 status: :not_found
          return
        end

        follow.destroy
        render json: { following_id: nil }, status: :no_content
      end
    end
  end
end
