module Frontend
  class FeedsController < FrontendController
    before_filter :set_conference, only: %i(podcast_folder broadcatching)

    # podcast_recent
    def podcast
      events = Event.newer(Time.now.ago(2.years))
      feed = Feeds::PodcastGenerator.new view_context: view_context,
        config: { title: 'recent events feed',
                  channel_summary: 'This feed contains events from the last two years' }
      xml = feed.generate events, :preferred_recording
      render xml: xml
    end

    def podcast_archive
      events = Event.older(Time.now.ago(2.years))
      feed = Feeds::PodcastGenerator.new view_context: view_context,
        config: { title: 'archive feed',
                  channel_summary: 'This feed contains events older than two years' }
      xml = feed.generate events, :preferred_recording
      render xml: xml
    end

    # TODO
    def podcast_audio
    end

    # rss 1.0 last 100 feed
    def updates
      events = Event.recent(100)
      feed = Feeds::RDFGenerator.new view_context: view_context,
        config: { title: 'last 100 events feed',
                  channel_summary: 'This feed the most recent 100 events' }
      xml = feed.generate events
      render xml: xml
    end

    def podcast_folder
      feeds = Feeds::PodcastGenerator.new view_context: view_context,
        config: { mime_type: @mime_type,
                  title: "#{@conference.title} (#{@mime_type_name})",
                  channel_summary: "This feed contains all events from #{@conference.acronym} as #{@mime_type_name}" }
      xml = feeds.generate downloaded_events, :by_mime_type
      render xml: xml
    end

    def broadcatching
      @feed = Feeds::BroadcatchingGenerator.generate events: downloaded_events, query: :by_mime_type, config: {
        mime_type: @mime_type,
        title: "#{@conference.title} (#{@mime_type_name})",
        channel_summary: "This feed contains all torrents for #{@mime_type_name} from #{@conference.acronym}"
      }

      respond_to do |format|
        format.xml { render :broadcatching }
      end
    end

    private

    def set_conference
      return unless params[:slug]
      return unless params[:mime_type]
      @conference = Conference.find_by!(slug: params[:slug])
      @mime_type, @mime_type_name = @conference.mime_types.find { |m, _n| m == params[:mime_type] }
      fail ArgumentError unless @mime_type
    end

    def downloaded_events
      @conference.events.select { |event| event.recordings.downloaded.any? }
    end
  end
end
