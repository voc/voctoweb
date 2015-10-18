module Frontend
  class FeedsController < FrontendController
    before_filter :set_conference, only: %i(podcast_folder)

    # podcast_recent
    def podcast
      events = Frontend::Event.newer(Time.now.ago(2.years)).includes(:conference)
      feed = Feeds::PodcastGenerator.new view_context: view_context,
        config: { title: 'recent events feed',
                  channel_summary: 'This feed contains events from the last two years',
                  logo: view_context.image_url('frontend/miro-banner.png') }
      xml = feed.generate events, :preferred_recording
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive
      events = Frontend::Event.older(Time.now.ago(2.years)).includes(:conference)
      feed = Feeds::PodcastGenerator.new view_context: view_context,
        config: { title: 'archive feed',
                  channel_summary: 'This feed contains events older than two years',
                  logo: view_context.image_url('frontend/miro-banner.png') }
      xml = feed.generate events, :preferred_recording
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_audio
      events = Frontend::Event.newer(Time.now.ago(1.years)).includes(:conference)
      feed = Feeds::PodcastGenerator.new view_context: view_context,
        config: { title: 'recent audio-only feed',
                  channel_summary: 'This feed contains events from the last years',
                  logo: view_context.image_url('frontend/miro-banner.png') }
      xml = feed.generate events, :audio_recording
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    # rss 1.0 last 100 feed
    def updates
      events = Frontend::Event.recent(100).includes(:conference)
      feed = Feeds::RDFGenerator.new view_context: view_context,
        config: { title: 'last 100 events feed',
                  channel_summary: 'This feed the most recent 100 events',
                  logo: view_context.image_url('frontend/miro-banner.png') }
      xml = feed.generate events
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_folder
      feeds = Feeds::PodcastGenerator.new view_context: view_context,
        config: { mime_type: @mime_type,
                  title: "#{@conference.title} (#{@mime_type_name})",
                  channel_summary: "This feed contains all events from #{@conference.acronym} as #{@mime_type_name}",
                  logo: view_context.image_url('frontend/miro-banner.png') }
      xml = feeds.generate downloaded_events, :by_mime_type
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    private

    def set_conference
      return unless params[:slug]
      return unless params[:mime_type]
      @conference = Frontend::Conference.find_by!(slug: params[:slug])
      @mime_type, @mime_type_name = @conference.mime_types.find { |m, n| n == params[:mime_type] }
      fail ArgumentError unless @mime_type
    end

    def downloaded_events
      @conference.events.select { |event| event.recordings.downloaded.any? }
    end
  end
end
