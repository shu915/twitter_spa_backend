# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < ApplicationController
        include ActionController::Cookies

        def create
          user = User.find_by(email: user_params[:email])
          if user&.valid_password?(user_params[:password])
            # トークンを生成
            token = user.create_new_auth_token

            cookies[:access_token] = {
              value: token['access-token'],
              httponly: true,
              secure: Rails.env.production?,  # HTTPSのみで送信（本番環境では必須）
              same_site: :strict               # サイト間リクエストの制御
            }
            
            cookies[:client] = {
              value: token['client'],
              httponly: true,
              secure: Rails.env.production?,
              same_site: :strict
            }
            
            cookies[:uid] = {
              value: token['uid'],
              httponly: true,
              secure: Rails.env.production?,
              same_site: :strict
            }
            # トークン情報をJSON形式で返す
            render json: {
              message: 'ログイン成功',
              user: user,
            }, status: :ok
          else
            render json: { message: 'ログイン失敗', errors: 'メールアドレスかパスワードが間違っています' }, status: :unauthorized
          end
        end

        private

        def user_params
          params.require(:user).permit(:email, :password)
        end
      end
    end
  end
end
