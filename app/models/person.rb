# frozen_string_literal: true

# Person model to represent speakers, authors, and other contributors
class Person < ApplicationRecord
  validates :name, presence: true

  has_many :participations, dependent: :destroy
  has_many :events, through: :participations
  has_many :person_identifiers, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :person_identifiers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank

  # Resolve a URL param that may be either an internal id or a person_identifier guid.
  def self.find_by_param!(param)
    return find(param) if param.to_s.match?(/\A\d+\z/)

    joins(:person_identifiers).find_by!(person_identifiers: { guid: param })
  end

  # Merge this person into target: moves identifiers and participations, then destroys self.
  # Skips participant records that would duplicate an existing (target, event) pair.
  def merge_into!(target)
    raise ArgumentError, 'Cannot merge a person into itself' if target == self

    transaction do
      person_identifiers.update_all(person_id: target.id)
      participations.each do |p|
        p.update!(person_id: target.id) unless target.participations.exists?(event_id: p.event_id)
      end
      destroy!
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[avatar_url created_at description email id name public_name updated_at]
  end

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
