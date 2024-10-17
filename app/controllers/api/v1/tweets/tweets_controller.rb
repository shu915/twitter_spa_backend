# frozen_string_literal: true

module Api
  module V1
    module Tweets
      class TweetsController < ApplicationController
        before_action :authenticate_user!

        def index
          render json: { message: 'ツイート一覧取得成功' }, status: :ok
        end
      end
    end
  end
end
