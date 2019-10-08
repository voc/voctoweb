module Frontend
  class FeedsController < FrontendController
    before_action :set_conference, only: %i(podcast_folder)
    FEEDS_EXPIRY_DURATION = 15.minutes

    def podcast
      events_max_age = round_to_quarter_hour(Time.now.ago(2.years))

      xml = cache_fetch(:podcast, params[:quality], events_max_age.to_i) do
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: "recent events feed (#{FeedQuality.display_name(params[:quality])})",
          channel_summary: ' This feed contains events from the last two years',
          logo_image: logo_image_url
        )
        feed.generate(downloaded_events.newer(events_max_age)) do |event|
          EventRecordingFilter.by_quality_string(params[:quality]).filter(event)
        end
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_legacy
      events_max_age = round_to_quarter_hour(Time.now.ago(2.years))

      xml = cache_fetch(:podcast_legacy, events_max_age.to_i) do
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: 'recent events feed',
          channel_summary: ' This feed contains events from the last two years',
          logo_image: logo_image_url
        )
        # Leave filter method like this to not change the results of the feed
        feed.generate(downloaded_events.newer(events_max_age), &:preferred_recording)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive
      events_min_age = round_to_quarter_hour(Time.now.ago(2.years))

      xml = cache_fetch(:podcast_archive, params[:quality], events_min_age.to_i) do
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: "archive feed (#{FeedQuality.display_name(params[:quality])})",
          channel_summary: ' This feed contains events older than two years',
          logo_image: logo_image_url
        )
        feed.generate(downloaded_events.older(events_min_age)) do |event|
          EventRecordingFilter.by_quality_string(params[:quality]).filter(event)
        end
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive_legacy
      events_min_age = round_to_quarter_hour(Time.now.ago(2.years))

      xml = cache_fetch(:podcast_archive_legacy, events_min_age.to_i) do
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: 'archive feed',
          channel_summary: ' This feed contains events older than two years',
          logo_image: logo_image_url
        )
        feed.generate(downloaded_events.older(events_min_age), &:preferred_recording)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_folder
      xml = cache_fetch(:podcast_folder, params[:quality], @conference, @mime_type) do

        mime_display_name = MimeType.humanized_mime_type(@mime_type)
        quality_display_name = FeedQuality.display_name(params[:quality])
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: "#{@conference.title} (#{[quality_display_name, mime_display_name].reject(&:empty?).join(' ')})",
          channel_summary: " This feed contains all events from #{@conference.acronym} as #{mime_display_name}",
          channel_description: " This feed contains all events from #{@conference.acronym} as #{mime_display_name}",
          base_url: view_context.conference_url(acronym: @conference.acronym),
          logo_image: @conference.logo_url
        )
        feed.generate(@conference.events.includes(:conference)) do |event|
          EventRecordingFilter
            .by_quality_string(params[:quality])
            .with_mime_type(@mime_type)
            .filter(event)
        end
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_audio
      events_max_age = round_to_quarter_hour(Time.now.ago(1.years))
      xml = cache_fetch(:podcast_audio, events_max_age.to_i) do
        feed = Feeds::PodcastGenerator.new(
          view_context,
          title: 'recent audio-only feed',
          channel_summary: ' This feed contains audio files from the last year',
          logo_image: logo_image_url
        )
        feed.generate(downloaded_events.newer(events_max_age), &:audio_recording)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    # rss 1.0 last 100 feed
    def updates
      xml = cache_fetch(:rdftop100) do
        events = downloaded_events.recent(100)
        feed = Feeds::RDFGenerator.new(
          view_context: view_context,
          config: {
             title: 'last 100 events feed',
             channel_summary: ' This feed the most recent 100 events',
             logo: logo_image_url
          }
        )
        feed.generate events
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    private

    def cache_fetch(*key)
      Rails.cache.fetch(key, expires_in: FEEDS_EXPIRY_DURATION) do
        yield if block_given?
      end
    end

    def downloaded_events
      Frontend::Event.includes(:conference)
    end

    def logo_image_url
      view_context.image_url('frontend/feed-banner.png')
    end

    def round_to_quarter_hour(time)
      seconds = 15 * 60
      Time.at((time.to_f / seconds).floor * seconds)
    end

    def set_conference
      @conference = if params[:acronym]
                      Frontend::Conference.find_by!(acronym: params[:acronym])
                    elsif params[:slug]
                      Frontend::Conference.find_by!(slug: params[:slug])
                    end

      @mime_type, @mime_type_name = @conference.mime_types.find { |_m, n| n == params[:mime_type] }
      fail ActiveRecord::RecordNotFound unless @mime_type
    end
  end
end
