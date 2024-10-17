# frozen_string_literal: true

module Api
  module V1
    module Users
      class RegistrationsController < ApplicationController
        def create
          user = User.new(sign_up_params)
          if user.save
            user.send_confirmation_instructions
            render json: {
              message: '登録成功'
            }, status: :created
          else
            render json: {
              message: '登録失敗',
              errors: user.errors.messages
            }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :name, :birthday)
        end
      end
    end
  end
end
