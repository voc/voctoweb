# frozen_string_literal: true

# Join model to associate people with events
class Participant < ApplicationRecord
  belongs_to :event
  belongs_to :person

  validates :event, :person, presence: true
  validates :person_id, uniqueness: { scope: :event_id }

  # Different roles a person can have in relation to an event
  enum role: { speaker: 0, moderator: 1, author: 2, contributor: 3 }
end
