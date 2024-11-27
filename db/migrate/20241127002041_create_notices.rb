# frozen_string_literal: true

class CreateNotices < ActiveRecord::Migration[7.0]
  def change
    create_table :notices do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :notifiable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
