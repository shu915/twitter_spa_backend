# frozen_string_literal: true

module TweetWithUserAndImage
  extend ActiveSupport::Concern

  def tweet_with_user_and_image_url(tweet)
    tweet.as_json(include: { user: { only: %i[id display_name account_name] } },
                  methods: :replies_count)
         .merge(
           image_url: tweet.image&.file&.attached? ? url_for(tweet.image.file) : nil,
           user_profile_image_url: tweet.user.profile_image.attached? ? url_for(tweet.user.profile_image) : nil
         )
  end
end
