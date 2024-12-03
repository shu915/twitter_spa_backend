# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :users, through: :entries
end
