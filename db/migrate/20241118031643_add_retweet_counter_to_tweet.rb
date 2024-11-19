# frozen_string_literal: true

class AddRetweetCounterToTweet < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :retweets_count, :integer, default: 0
  end
end
