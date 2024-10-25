# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  include DeviseTokenAuth::Concerns::User

  validates :account_name, presence: true, length: { in: 3..16 }, uniqueness: true, format: { with: /\A[a-zA-Z0-9]+\z/, message: 'は半角英数字で入力してください' }
  validates :display_name, presence: true, length: { in: 3..16 }
  validates :birthday, presence: true

  has_many :tweets, dependent: :destroy
  has_one_attached :profile_image
  has_one_attached :header_image

  after_create :attach_default_images

  def profile_image_url
    Rails.application.routes.url_helpers.rails_blob_url(profile_image) if profile_image.attached?
  end

  def header_image_url
    Rails.application.routes.url_helpers.rails_blob_url(header_image, only_path: true) if header_image.attached?
  end

  private

  def attach_default_images
    profile_image.attach(io: Rails.public_path.join('images/default_profile_image.webp').open,
                         filename: 'default_profile_image.webp', content_type: 'image/webp')
    header_image.attach(io: Rails.public_path.join('images/default_header_image.webp').open, filename: 'default_header_image.webp',
                        content_type: 'image/webp')
  end
end
