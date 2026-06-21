# frozen_string_literal: true

# Computes what a schedule import would change without persisting anything.
# Returns three arrays: person_changes, participation_changes, event_changes.
class ScheduleImportPreview
  PersonChange       = Data.define(:status, :attrs, :existing, :field_changes)
  ParticipationChange = Data.define(:status, :event, :person_attrs)
  EventChange        = Data.define(:event, :field_changes)

  EVENT_FIELDS   = %i[title description subtitle slug persons].freeze
  PERSON_FIELDS  = %i[public_name avatar_url description].freeze

  def initialize(conference)
    @conference = conference
  end

  def run
    parser = @conference.schedule_parser
    {
      person_changes:        person_changes(parser),
      participation_changes: participation_changes(parser),
      event_changes:         event_changes(parser)
    }
  end

  private

  # ── Persons ───────────────────────────────────────────────────────────────

  def person_changes(parser)
    return [] unless parser.respond_to?(:persons_by_event_guid)

    by_guid, by_name = load_existing_people(unique_person_attrs(parser))

    unique_person_attrs(parser).map do |attrs|
      existing = by_guid[attrs[:guid]] || by_name[attrs[:name]]
      if existing.nil?
        PersonChange.new(status: :create, attrs: attrs, existing: nil, field_changes: {})
      else
        changes = PERSON_FIELDS.each_with_object({}) do |field, h|
          new_val = attrs[field].presence
          next unless new_val
          old_val = existing.public_send(field)
          h[field] = [old_val, new_val] unless old_val.to_s == new_val.to_s
        end
        PersonChange.new(status: :update, attrs: attrs, existing: existing, field_changes: changes)
      end
    end
  end

  # ── Participations ────────────────────────────────────────────────────────

  def participation_changes(parser)
    return [] unless parser.respond_to?(:persons_by_event_guid)

    events_by_guid = load_conference_events(parser.persons_by_event_guid.keys)
    by_guid, by_name = load_existing_people(unique_person_attrs(parser))

    existing_pairs = Participation.joins(:event)
                                  .where(events: { conference_id: @conference.id })
                                  .pluck(:event_id, :person_id).to_set

    parser.persons_by_event_guid.flat_map do |event_guid, persons|
      event = events_by_guid[event_guid]
      next [] unless event

      persons.filter_map do |attrs|
        person = by_guid[attrs[:guid]] || by_name[attrs[:name]]
        next if person && existing_pairs.include?([event.id, person.id])

        ParticipationChange.new(
          status:      person ? :new : :new_with_person,
          event:       event,
          person_attrs: attrs
        )
      end
    end
  end

  # ── Event metadata ────────────────────────────────────────────────────────

  def event_changes(parser)
    info_by_guid   = parser.event_info_by_guid
    events_by_guid = load_conference_events(info_by_guid.keys)

    info_by_guid.filter_map do |guid, info|
      event = events_by_guid[guid]
      next unless event

      changes = EVENT_FIELDS.each_with_object({}) do |field, h|
        old_val = event.public_send(field)
        new_val = info[field]
        h[field] = [old_val, new_val] unless old_val.to_s == new_val.to_s
      end
      EventChange.new(event: event, field_changes: changes) if changes.any?
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  def unique_person_attrs(parser)
    return [] unless parser.respond_to?(:persons_by_event_guid)

    @unique_person_attrs ||= begin
      seen = Set.new
      parser.persons_by_event_guid.values.flatten.select do |attrs|
        key = attrs[:guid] || attrs[:name]
        seen.add?(key)
      end
    end
  end

  def load_existing_people(attrs_list)
    guids = attrs_list.map { |a| a[:guid] }.compact
    names = attrs_list.map { |a| a[:name] }.compact

    by_guid = PersonIdentifier.where(guid: guids, source: 'schedule').includes(:person)
                              .each_with_object({}) { |pi, h| h[pi.guid] = pi.person }

    matched_names = attrs_list.reject { |a| by_guid[a[:guid]] }.map { |a| a[:name] }
    by_name = Person.where(name: matched_names).index_by(&:name)

    [by_guid, by_name]
  end

  def load_conference_events(guids)
    Event.where(guid: guids, conference_id: @conference.id).index_by(&:guid)
  end
end
