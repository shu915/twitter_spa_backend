# frozen_string_literal: true

class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :following, null: false, foreign_key: { to_table: :users }
      t.timestamps

      t.index %i[follower_id following_id], unique: true
    end
  end
end
