# frozen_string_literal: true

class Tweet < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  validates :content, presence: true, length: { maximum: 140 }
end
