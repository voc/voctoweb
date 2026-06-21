# frozen_string_literal: true

# Join model to associate people with events
class Participation < ApplicationRecord
  belongs_to :event
  belongs_to :person

  validates :event, :person, presence: true
  validates :person_id, uniqueness: { scope: :event_id }

  scope :ordered, -> { left_joins(:person).order(Arel.sql('participations.order IS NULL, participations.order ASC, people.name ASC')) }

  # Different roles a person can have in relation to an event
  enum role: { speaker: 0, moderator: 1, author: 2, contributor: 3, producer: 4 }
end
