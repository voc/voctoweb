# frozen_string_literal: true

# Parser for the pretalx schedule.json format (schedule1 / c3voc schema v1).
# Events are nested under schedule.conference.days[].rooms{}.
# Person details live inline on each event's persons[].
module Schedule1JsonParser
  class Schedule1JsonParser
    def initialize(json)
      @conference = JSON.parse(json).dig('schedule', 'conference')
    end

    def event_info_by_guid
      @event_info_by_guid ||= all_events.each_with_object({}) do |ev, hash|
        hash[ev['guid']] = {
          id:          ev['id'].to_s,
          title:       ev['title'],
          description: ev['abstract'].presence || ev['description'],
          tags:        [ev['track']].compact,
          date:        ev['date'],
          subtitle:    ev['subtitle'],
          slug:        ev['slug'],
          link:        ev['url'],
          persons:     ev['persons'].map { |p| p['public_name'].presence || p['name'] }
        }
      end
    end

    def persons_by_event_guid
      @persons_by_event_guid ||= all_events.each_with_object({}) do |ev, hash|
        hash[ev['guid']] = ev['persons'].map { |p| parse_person(p) }
      end
    end

    private

    def parse_person(p)
      public_name = p['public_name'].presence
      public_name = nil if public_name == p['name']
      {
        guid:        p['guid'],
        name:        p['name'],
        public_name: public_name,
        avatar_url:  p['avatar'],
        description: p['biography'],
        url:         p['url'],
        role:        :speaker
      }
    end

    def all_events
      @all_events ||= @conference['days'].flat_map do |day|
        day['rooms'].flat_map { |_room, events| events }
      end
    end
  end
end
