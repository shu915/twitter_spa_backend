# frozen_string_literal: true

class Image < ApplicationRecord
  has_one_attached :file, dependent: :purge
  belongs_to :tweet

  validates :file, presence: true
  validate :validate_image_file_type

  private

  def validate_image_file_type
    return unless file.attached?

    return if file.blob.content_type.in?(['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/webp'])

    errors.add(:image, 'は許可されていないファイル形式です')
  end
end
