# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies do |t|
      t.references :parent_tweet, null: false, foreign_key: { to_table: :tweets }
      t.references :child_tweet, null: false, foreign_key: { to_table: :tweets }

      t.timestamps
    end
  end
end
