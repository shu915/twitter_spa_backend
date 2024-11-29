# frozen_string_literal: true

class Retweet < ApplicationRecord
  belongs_to :user
  belongs_to :tweet, counter_cache: true

  has_many :notices, as: :notifiable, dependent: :destroy

  after_create_commit do
    notices.create!(sender: user, receiver: tweet.user)
  end
end
