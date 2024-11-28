# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :parent_tweet, class_name: 'Tweet', inverse_of: :replies_as_parent, counter_cache: true
  belongs_to :child_tweet, class_name: 'Tweet', inverse_of: :replies_as_child

  has_many :notices, as: :notifiable, dependent: :destroy

  after_create_commit do
    notices.create!(sender: child_tweet.user, receiver: parent_tweet.user)
  end
end
