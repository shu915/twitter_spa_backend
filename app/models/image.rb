# frozen_string_literal: true

class Image < ApplicationRecord
  has_one_attached :file, dependent: :purge
  belongs_to :tweet

  validates :file, presence: true, content_type: { in: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/webp'], message: 'は許可されていないファイル形式です' },
                    size: { less_than: 5.megabytes, message: 'は5MB以下である必要があります' }
  private

end
