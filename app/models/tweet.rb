# frozen_string_literal: true

class Tweet < ApplicationRecord
  belongs_to :user
  has_one :image, dependent: :destroy

  has_many :replies_as_parent, class_name: 'Reply', foreign_key: 'parent_tweet_id', inverse_of: :parent_tweet, dependent: :destroy
  has_many :children, through: :replies_as_parent, source: :child_tweet

  has_one :replies_as_child, class_name: 'Reply', foreign_key: 'child_tweet_id', inverse_of: :child_tweet, dependent: :destroy
  has_one :parent, through: :replies_as_child, source: :parent_tweet

  validates :content, presence: true, length: { maximum: 140 }

  def ancestor_ids
    ids = []
    current_id = id

    while (parent_id = Reply.where(child_tweet_id: current_id)
                         .limit(1)
                         .pick(:parent_tweet_id))
      ids << parent_id
      current_id = parent_id
    end

    ids
  end

  def child_ids
    Reply.where(parent_tweet_id: id).pluck(:child_tweet_id)
  end
end
