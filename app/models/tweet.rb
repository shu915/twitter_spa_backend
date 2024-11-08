# frozen_string_literal: true

class Tweet < ApplicationRecord
  belongs_to :user
  has_one :image, dependent: :destroy

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :replies_as_parent, class_name: 'Reply', foreign_key: 'parent_tweet_id', inverse_of: :parent_tweet
  has_many :children, through: :replies_as_parent, source: :child_tweet

  has_many :replies_as_child, class_name: 'Reply', foreign_key: 'child_tweet_id', inverse_of: :child_tweet
  has_one :parent, through: :replies_as_child, source: :parent_tweet
  # rubocop:enable Rails/HasManyOrHasOneDependent

  validates :content, presence: true, length: { maximum: 140 }
end
