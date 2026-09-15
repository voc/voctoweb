# frozen_string_literal: true

# Parser for the pretalx schedule.json format (schedule1 / c3voc schema v1).
# Events are nested under schedule.conference.days[].rooms{}.
# Person details live inline on each event's persons[].
module Schedule1JsonParser
  class Schedule1JsonParser
    def initialize(json, speakers_json: nil)
      @conference = JSON.parse(json).dig('schedule', 'conference')
      @speakers_by_id = parse_speakers(speakers_json) if speakers_json.present?
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

    def parse_person(person)
      speaker     = @speakers_by_id&.fetch(person['id'], nil)
      # frab inline has only id + public_name; pretalx inline has name + public_name + guid
      full_name   = speaker&.dig(:full_name) || person['name'] || person['public_name']
      public_name = person['public_name'].presence
      public_name = nil if public_name == full_name
      # use UUID guid when present (pretalx); fall back to stringified integer id (frab)
      guid        = person['guid'].presence || person['id']&.to_s
      {
        guid:        guid,
        name:        full_name,
        public_name: public_name,
        avatar_url:  speaker&.dig(:image) || person['avatar'],
        description: speaker&.dig(:description) || person['biography'],
        url:         speaker&.dig(:url) || person['url'],
        role:        :speaker
      }
    end

    def parse_speakers(speakers_json)
      JSON.parse(speakers_json).dig('schedule_speakers', 'speakers').each_with_object({}) do |speaker, hash|
        hash[speaker['id']] = {
          full_name:   speaker['full_public_name'],
          image:       speaker['image'],
          description: speaker['abstract'].presence || speaker['description'],
          url:         speaker['links']&.first&.dig('url')
        }
      end
    end

    def all_events
      @all_events ||= @conference['days'].flat_map do |day|
        day['rooms'].flat_map { |_room, events| events }
      end
    end
  end
end
