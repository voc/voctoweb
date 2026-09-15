# frozen_string_literal: true

class PersonIdentifier < ApplicationRecord
  belongs_to :person

  acts_as_list scope: :person_id, column: :order

  validates :guid, presence: true
  validates :guid, uniqueness: { scope: :source, message: 'already exists for this source' }

  # keep this in sync with filters in app/admin/person_identifier.rb
  def self.ransackable_attributes(*)
    %w[guid source origin]
  end

  def self.ransackable_associations(*)
    %w[person]
  end
end
