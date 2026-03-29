# frozen_string_literal: true

# Person model to represent speakers, authors, and other contributors
class Person < ApplicationRecord
  validates :name, presence: true

  # Add associations to events through a join table
  has_many :events, through: :participans

  # Find or create a person by name
  def self.find_or_create_by_name(name)
    return nil if name.blank?

    find_by(name: name) || create(name: name)
  end

  # Convert a list of names to Person objects
  def self.from_names(names)
    Array(names).map { |name| find_or_create_by_name(name) }
  end

end
