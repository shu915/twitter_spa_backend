# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :parent_tweet, class_name: 'Tweet', inverse_of: :replies_as_parent, counter_cache: true
  belongs_to :child_tweet, class_name: 'Tweet', inverse_of: :replies_as_child

  has_many :notices, as: :notifiable, dependent: :destroy

  after_create_commit :create_notice

  private

  def create_notice
    Notice.create(sender: child_tweet.user, receiver: parent_tweet.user, notifiable_type: 'Reply', notifiable_id: id)
  end
end
