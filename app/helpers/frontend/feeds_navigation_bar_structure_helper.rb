module Frontend
  module FeedsNavigationBarStructureHelper
    SD_LABEL = 'SD quality'

    # rendered by _navbar_feeds.haml
    def feed_structure
      menu = [
          { :left =>{ :content => 'News', :href => '/news.atom' } },
          { :left => { :content => 'RSS, last 100', :href => '/updates.rdf' } },
          { :left => { :content => 'Podcast feed of the last two years', :href => '/podcast-hq.xml' },
                :right =>
                    { :content => SD_LABEL, :href => '/podcast-lq.xml', :title =>  'Podcast feed of the last two years (SD)'} },
          { :left => { :content => 'Podcast audio feed of the last year', :href => '/podcast-audio-only.xml' } },
          { :left => { :content => 'Podcast archive feed, everything older than two years', :href => '/podcast-archive-hq.xml' },
                :right =>
                    { :content => SD_LABEL, :href => '/podcast-archive-lq.xml', :title =>  'Podcast archive feed, everything older than two years (SD)'} } ]

      if @conference && @conference.downloaded_events_count > 0
        menu += add_feeds_for_conference_recordings(@conference)
      end
      menu
    end

    private

    def add_feeds_for_conference_recordings(conference)
      sub_menu = []
      sorted_mime_types = conference.mime_type_names.sort_by(&MimeType::RELEVANCE_COMPARATOR)
      sorted_mime_types.each do |mime_type, mime_type_name|
        if MimeType.is_video(mime_type)
          sub_menu.push({
            :left => {
              :indented => 'indented',
              :content  => MimeType.humanized_mime_type(mime_type),
              :href => podcast_folder_video_feed_url(acronym: conference.acronym, mime_type: mime_type_name, quality: FeedQuality::HQ),
              :title => MimeType.humanized_mime_type(mime_type)
            },
            :right => {
              :content => SD_LABEL,
              :href => podcast_folder_video_feed_url(acronym: conference.acronym, mime_type: mime_type_name, quality: FeedQuality::LQ),
              :title => MimeType.humanized_mime_type(mime_type) + ' (SD)'
            }
          })
        else
          sub_menu.push({
            :left => {
              :indented => 'indented',
              :content  => MimeType.humanized_mime_type(mime_type),
              :href => podcast_folder_feed_url(acronym: conference.acronym, mime_type: mime_type_name),
              :title => MimeType.humanized_mime_type(mime_type)
            }
          })
        end

      end

      unless sub_menu.empty?
        sub_menu.unshift({:headline => "Podcast feeds for #{conference.acronym}"})
      end

      sub_menu
    end

  end
end
