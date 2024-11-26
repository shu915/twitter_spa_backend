# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!
      rescue_from ActiveRecord::RecordNotFound do |_e|
        render json: { error: 'ユーザーが見つかりません' }, status: :not_found
      end

      def show
        user = User.find(params[:id])

        following_id = current_api_v1_user.active_follows.includes(:following).find_by(following: user)&.id

        render json: user.as_json.merge(
          header_image_url: user.header_image.attached? ? url_for(user.header_image) : nil,
          profile_image_url: user.profile_image.attached? ? url_for(user.profile_image) : nil,
          following_id:
        ), status: :ok
      end

      def update
        user = User.find(params[:id])
        if current_api_v1_user.id == user.id
          update_profile(user)
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      private

      def profile_params
        params.require(:user).permit(:display_name, :account_name, :bio, :location, :website, :profile_image, :header_image)
      end

      def update_profile(user)
        user.profile_image.attach(profile_params[:profile_image]) if profile_params[:profile_image].present?
        user.header_image.attach(profile_params[:header_image]) if profile_params[:header_image].present?

        if user.update(profile_params)
          render json: user.as_json.merge(
            header_image_url: user.header_image.attached? ? url_for(user.header_image) : nil,
            profile_image_url: user.profile_image.attached? ? url_for(user.profile_image) : nil
          ), status: :ok
        else
          render json: { error: user.errors.messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
