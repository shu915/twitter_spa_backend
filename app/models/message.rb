# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
