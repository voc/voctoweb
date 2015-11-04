module Frontend
  class FeedsController < FrontendController
    before_filter :set_conference, only: %i(podcast_folder)
    EXPIRE_FEEDS = 15

    # podcast_recent
    def podcast
      time = round_time(Time.now.ago(2.years))
      xml = Rails.cache.fetch([time, :podcast], expires_in: EXPIRE_FEEDS.minutes) do
        Feeds::PodcastGenerator.create_preferred(
          title: 'recent events feed', summary: 'This feed contains events from the last two years',
          logo: logo_image_url,
          events: downloaded_events.newer(time))
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive
      time = round_time(Time.now.ago(2.years))
      xml = Rails.cache.fetch([time, :podcast_archive], expires_in: EXPIRE_FEEDS.minutes) do
        Feeds::PodcastGenerator.create_preferred(
          title: 'archive feed', summary: 'This feed contains events older than two years',
          logo: logo_image_url,
          events: downloaded_events.older(time))
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_audio
      time = round_time(Time.now.ago(1.years))
      xml = Rails.cache.fetch([time, :podcast_audio], expires_in: EXPIRE_FEEDS.minutes) do
        events = downloaded_events.newer(time)
        Feeds::PodcastGenerator.create_audio(
          title: 'recent audio-only feed', summary: 'This feed contains events from the last years',
          logo: logo_image_url,
          events: events)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    # rss 1.0 last 100 feed
    def updates
      xml = Rails.cache.fetch(:rdftop100, expires_in: EXPIRE_FEEDS.minutes) do
        events = downloaded_events.recent(100)
        feed = Feeds::RDFGenerator.new view_context: view_context,
          config: { title: 'last 100 events feed',
                    channel_summary: 'This feed the most recent 100 events',
                    logo: view_context.image_url('frontend/miro-banner.png') }
        feed.generate events
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_folder
      xml = Rails.cache.fetch([@conference, @mime_type]) do
        Feeds::PodcastGenerator.create_mime_type(
          title: "#{@conference.title} (#{@mime_type_name})",
          summary: "This feed contains all events from #{@conference.acronym} as #{@mime_type_name}",
          logo: logo_image_url,
          events: @conference.downloaded_events.includes(:recordings),
          mime_type: @mime_type)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    private

    def downloaded_events
      Frontend::Event.downloaded.includes(:conference, :recordings)
    end

    def logo_image_url
      view_context.image_url('frontend/miro-banner.png')
    end

    def round_time(time)
      seconds = 15 * 60
      Time.at((time.to_f / seconds).floor * seconds)
    end

    def set_conference
      @conference = if params[:acronym]
                      Frontend::Conference.find_by!(acronym: params[:acronym])
                    elsif params[:slug]
                      Frontend::Conference.find_by!(slug: params[:slug])
                    end
      fail ActiveRecord::RecordNotFound unless @conference

      @mime_type, @mime_type_name = @conference.mime_types.find { |_m, n| n == params[:mime_type] }
      fail ActiveRecord::RecordNotFound unless @mime_type
    end
  end
end
