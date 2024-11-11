# frozen_string_literal: true

class AddRepliesCounterToTweet < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :replies_count, :integer, default: 0
  end
end
