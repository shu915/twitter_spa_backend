# frozen_string_literal: true

class Notice < ApplicationRecord
  belongs_to :sender, class_name: 'User', inverse_of: :sent_notices
  belongs_to :receiver, class_name: 'User', inverse_of: :received_notices
  belongs_to :notifiable, polymorphic: true

  after_create :send_notification_email

  private

  def send_notification_email
    NoticeMailer.with(notice: self).new_notification_email.deliver_now
  end
end
