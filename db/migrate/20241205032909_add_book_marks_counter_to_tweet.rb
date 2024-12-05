# frozen_string_literal: true

class AddBookMarksCounterToTweet < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :bookmarks_count, :integer, default: 0
  end
end
