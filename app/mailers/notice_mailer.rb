# frozen_string_literal: true

class NoticeMailer < ApplicationMailer
  default from: 'no-reply@yourdomain.com' # 差出人の設定

  def new_notification_email
    notice = params[:notice]
    receiver = notice.receiver

    case notice.notifiable_type
    when 'Reply'
      @text = "#{notice.sender.display_name}さんがあなたのツイートに返信をしました。"
    when 'Retweet'
      @text = "#{notice.sender.display_name}さんがあなたのツイートをリツイートしました。"
    when 'Like'
      @text = "#{notice.sender.display_name}さんがあなたのツイートをいいねしました。"
    when 'Follow'
      @text = "#{notice.sender.display_name}さんがあなたをフォローしました。"
    end

    mail(
      to: receiver.email, # 通知を受け取る人のメールアドレス
      subject: '新しい通知が届きました'
    )
  end
end
