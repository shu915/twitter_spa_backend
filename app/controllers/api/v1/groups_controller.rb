# frozen_string_literal: true

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
        groups = Group.joins(:entries)
                      .where(entries: { user_id: current_api_v1_user.id })
                      .includes(entries: { user: { profile_image_attachment: :blob } })

        groups_with_avatars = groups.map do |group|
          other_user = group.entries.map(&:user).find { |user| user.id != current_api_v1_user.id }
          {
            id: group.id,
            target_user: {
              id: other_user.id,
              display_name: other_user.display_name,
              account_name: other_user.account_name,
              profile_image_url: other_user.profile_image_url
            },
            last_message: group.messages.last.content,
            last_message_created_at: group.messages.last.created_at.strftime('%m月%d日 %H:%M')
          }
        end

        render json: groups_with_avatars
      end

      def create
        user_ids = [current_api_v1_user.id, group_params[:target_user_id]]
        target_group = Group.joins(:entries)
                            .where(entries: { user_id: user_ids })
                            .group('groups.id')
                            .having('COUNT(entries.user_id) = ?', user_ids.size)
                            .first

        unless target_group
          group = Group.create!
          user_ids.each do |user_id|
            Entry.create!(group:, user_id:)
          end
          target_group = group
        end

        render json: target_group
      end

      private

      def group_params
        params.require(:group).permit(:target_user_id)
      end
    end
  end
end
