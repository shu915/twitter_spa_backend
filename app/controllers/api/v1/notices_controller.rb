# frozen_string_literal: true

module Api
  module V1
    class NoticesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        notices = current_api_v1_user.received_notices.includes(sender: [profile_image_attachment: :blob], notifiable: %i[tweet reply]).order(created_at: :desc)

        filtered_notices = notices.map do |notice|
          if notice.notifiable_type == 'Follow'
            notice.as_json(include: { sender: { methods: :profile_image_url } })
          elsif notice.notifiable_type == 'Reply'
            notice.as_json(include: { sender: { methods: :profile_image_url }, notifiable: { methods: %i[parent_tweet child_tweet] } })
          else
            notice.as_json(include: { sender: { methods: :profile_image_url }, notifiable: { methods: :tweet } })
          end
        end

        render json: filtered_notices
      end
    end
  end
end
