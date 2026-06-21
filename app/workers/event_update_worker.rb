class EventUpdateWorker
  include Sidekiq::Worker

  # bulk update several events using the saved schedule files
  def perform(ids)
    logger.info "bulk updating events from schedule for events: #{ids.join(', ')}"
    @parsers = {}
    @event_infos = {}

    ActiveRecord::Base.transaction do
      Event.where(id: ids).each do |event|
        conference = event.conference

        parser = parser_for_conference(conference)
        next unless parser

        info = event_info(parser, event.guid)
        next unless info.present?

        event.update_event_info(info)
      end
    end
  end

  private

  def parser_for_conference(conference)
    @parsers[conference.acronym] ||= conference.schedule_parser
  rescue StandardError => e
    logger.error "could not build schedule parser for #{conference.acronym}: #{e.message}"
    nil
  end

  def event_info(parser, guid)
    @event_infos[parser] ||= parser.event_info_by_guid
    @event_infos[parser][guid]
  end
end
