# frozen_string_literal: true

class AddFollowCountersToUsers < ActiveRecord::Migration[7.0]
  change_table :users, bulk: true do |t|
    t.integer :followers_count, default: 0
    t.integer :followings_count, default: 0
  end
end
