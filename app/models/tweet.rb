# frozen_string_literal: true

class Tweet < ApplicationRecord
  belongs_to :user
  has_one :image, dependent: :destroy

  validates :content, presence: true, length: { maximum: 140 }
end
