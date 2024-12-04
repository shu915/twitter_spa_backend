# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
