# frozen_string_literal: true

class PersonIdentifier < ApplicationRecord
  belongs_to :person

  validates :guid, presence: true
  validates :guid, uniqueness: { scope: :source, message: 'already exists for this source' }
end
