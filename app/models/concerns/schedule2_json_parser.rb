# frozen_string_literal: true

# Parser for the c3voc hub schedule2 format (https://c3voc.de/schema/schedule2).
# Events are a flat array at schedule.events[].
# Full person records live at schedule.persons[] and are referenced by guid
# from each event's participants[].
module Schedule2JsonParser
  class Schedule2JsonParser
    ROLE_MAP = {
      'SPEAKER'     => :speaker,
      'MODERATOR'   => :moderator,
      'CONTRIBUTOR' => :contributor,
      'HOST'        => :moderator,
      'GUEST'       => :contributor
    }.freeze

    def initialize(json)
      data = JSON.parse(json)['schedule']
      @events  = data['events'] || []
      @persons = data['persons']&.index_by { |p| p['guid'] } || {}
    end

    def event_info_by_guid
      @event_info_by_guid ||= @events.each_with_object({}) do |ev, hash|
        next unless ev['guid']

        hash[ev['guid']] = {
          id:          nil,
          title:       ev['title'],
          description: ev['abstract'].presence || ev['description'],
          tags:        [ev.dig('track', 'slug')].compact,
          date:        ev['start'],
          subtitle:    ev['subtitle'],
          slug:        ev['slug'],
          link:        ev['url'],
          persons:     (ev['participants'] || []).map { |p| person_name(p) }
        }
      end
    end

    def persons_by_event_guid
      @persons_by_event_guid ||= @events.each_with_object({}) do |ev, hash|
        next unless ev['guid']

        hash[ev['guid']] = (ev['participants'] || []).map { |p| parse_participant(p) }
      end
    end

    private

    def person_name(participant)
      @persons.dig(participant['guid'], 'name') || participant['name']
    end

    def parse_participant(participant)
      full = @persons[participant['guid']] || {}
      {
        guid:        participant['guid'],
        name:        full['name'] || participant['name'],
        public_name: nil,
        avatar_url:  full.dig('avatar', 'url'),
        description: full['biography'],
        url:         full['url'],
        role:        ROLE_MAP.fetch(participant['role'], :speaker)
      }
    end
  end
end
