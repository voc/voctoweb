# frozen_string_literal: true

class PersonImportWorker
  include Sidekiq::Worker

  def perform(conference_id)
    conference = Conference.find(conference_id)
    return unless conference.downloaded?

    parser = conference.schedule_parser
    return unless parser.respond_to?(:persons_by_event_guid)

    info_by_guid     = parser.event_info_by_guid
    persons_by_event = parser.persons_by_event_guid
    store_schedule   = Event.column_names.include?('schedule')

    ActiveRecord::Base.transaction do
      conference.events.each do |event|
        if store_schedule && (info = info_by_guid[event.guid])
          event.update_column(:schedule, info)
        end

        (persons_by_event[event.guid] || []).each_with_index do |attrs, index|
          person = upsert_person(attrs)
          participation = Participation.find_or_initialize_by(event: event, person: person)
          participation.role  = attrs[:role] if attrs[:role]
          participation.order = index
          participation.url   = attrs[:url].presence
          participation.save!
        end
      end
    end
  end

  private

  def upsert_person(attrs)
    person = find_by_guid(attrs[:guid]) ||
             Person.find_by(name: attrs[:name]) ||
             Person.new(name: attrs[:name])

    updates = attrs.slice(:public_name, :avatar_url, :description).compact_blank
    person.assign_attributes(updates)
    person.save!

    ensure_identifier(person, attrs[:guid])
    person
  end

  def find_by_guid(guid)
    return if guid.blank?

    PersonIdentifier.find_by(guid: guid, source: 'schedule')&.person
  end

  def ensure_identifier(person, guid)
    return if guid.blank?

    PersonIdentifier.find_or_create_by!(guid: guid, source: 'schedule') do |pi|
      pi.person = person
    end
  end
end
