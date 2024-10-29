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

            # トークン情報をJSON形式で返す
            render json: {
              message: 'ログイン成功',
              user: {
                id: user.id,
                account_name: user.account_name,
                display_name: user.display_name,
                birthday: user.birthday,
                bio: user.bio,
                location: user.location,
                website: user.website,
                email: user.email,
                profile_image_url: user.profile_image_url,
                header_image_url: user.header_image_url
              },
              access_token: token['access-token'],
              client: token['client'],
              uid: token['uid']
            }, status: :ok
          else
            render json: { message: 'ログイン失敗', errors: 'メールアドレスかパスワードが間違っています' }, status: :unauthorized
          end
        end

        def destroy
          # トークンの無効化（例: Devise Token Authを使用している場合）
          if current_api_v1_user
            current_api_v1_user.tokens = {}
            current_api_v1_user.save
          end

          render json: { message: 'ログアウト成功' }, status: :ok
        end

        private

        def user_params
          params.require(:user).permit(:email, :password)
        end
      end
    end
  end
end
