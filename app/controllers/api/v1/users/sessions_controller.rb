# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < ApplicationController
        def create
          user = User.find_by(email: user_params[:email])
          if user&.valid_password?(user_params[:password])
            # トークンを生成
            token = user.create_new_auth_token

            # トークン情報をJSON形式で返す
            render json: {
              data: user.as_json.merge({
                                         access_token: token['access-token'],
                                         client: token['client'],
                                         uid: token['uid']
                                       })
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
