module Frontend
  class FeedsController < FrontendController
    before_filter :set_conference, only: %i(podcast_folder)

    # podcast_recent
    def podcast
      events = downloaded_events.newer(Time.now.ago(2.years))
      xml = Rails.cache.fetch(key_for_events(events, :podcast)) do
        Feeds::PodcastGenerator.create_preferred(
          title: 'recent events feed', summary: 'This feed contains events from the last two years',
          logo: logo_image_url,
          events: events)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive
      events = downloaded_events.older(Time.now.ago(2.years))
      xml = Rails.cache.fetch(key_for_events(events, :podcast_archive)) do
        Feeds::PodcastGenerator.create_preferred(
          title: 'archive feed', summary: 'This feed contains events older than two years',
          logo: logo_image_url,
          events: events)
      end
      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_audio
      events = downloaded_events.newer(Time.now.ago(1.years))
      xml = Rails.cache.fetch(key_for_events(events, :podcast_audio)) do
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
      events = downloaded_events.recent(100)
      xml = Rails.cache.fetch(key_for_events(events, :rdftop100)) do
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
          events: @conference.events.downloaded.includes(:recordings),
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

    def key_for_events(events, name)
      key = events.map(&:cache_key).join('/')
      name.to_s + '/' + Digest::SHA1.hexdigest(key)
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
