class Feed::FolderWorker < Feed::Base
  include Sidekiq::Worker

  key :podcast_folder

  def perform(*args)
    start_time = Time.now

    conference = Frontend::Conference.find(args[0])
    conference.mime_type_names.each do |mime_type, mime_type_name|
      if MimeType.is_audio(mime_type)
        kind = WebFeed.folder_key(conference, '', mime_type_name)

        WebFeed.update_with_lock(start_time, key: key, kind: kind) do |feed|
          feed.content = build(conference, mime_type, mime_type_name, '')
        end
      elsif MimeType.is_video(mime_type)
        Frontend::FeedQuality.all.each do |quality|
          kind = WebFeed.folder_key(conference, quality, mime_type_name)

          WebFeed.update_with_lock(start_time, key: key, kind: kind) do |feed|
            feed.content = build(conference, mime_type, mime_type_name, quality)
          end
        end
      end
    end
  end

  private

  def build(conference, mime_type, mime_type_name, quality)
    quality_display_name = Frontend::FeedQuality.display_name(quality)
    generator = Feeds::PodcastGenerator.new(
      view_context,
      title: "#{conference.title} (#{[quality_display_name, mime_type_name].reject(&:empty?).join(' ')})",
      channel_summary: " This feed contains all events from #{conference.acronym} as #{mime_type_name}",
      channel_description: " This feed contains all events from #{conference.acronym} as #{mime_type_name}",
      base_url: view_context.conference_url(acronym: conference.acronym),
      logo_image: conference.logo_url
    )
    generator.generate(conference.events.released.includes(:conference)) do |event|
      Frontend::EventRecordingFilter
        .by_quality_string(quality)
        .with_mime_type(mime_type)
        .filter(event)
    end
  end
end
