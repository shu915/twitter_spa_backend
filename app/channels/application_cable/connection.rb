# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      client_id = request.params[:client_id]
      uid = request.params[:uid]
      Rails.logger.info "Token: #{token}, Client ID: #{client_id}, UID: #{uid}"

      user = User.find_by(uid:)
      if user&.valid_token?(token, client_id)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
