# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User', counter_cache: :followings_count
  belongs_to :following, class_name: 'User', counter_cache: :followers_count
end
