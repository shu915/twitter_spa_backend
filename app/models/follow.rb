# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User', counter_cache: :followings_count
  belongs_to :following, class_name: 'User', counter_cache: :followers_count

  has_many :notices, as: :notifiable, dependent: :destroy

  after_create_commit :create_notice

  private

  def create_notice
    Notice.create(sender: follower, receiver: following, notifiable_type: 'Follow', notifiable_id: id)
  end
end
