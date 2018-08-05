module Frontend
  require "date"

  class Event < ::Event
    index_name "media-event-#{Rails.env}"
    document_type 'event'

    belongs_to :conference, class_name: 'Frontend::Conference'
    has_many :recordings, class_name: 'Frontend::Recording'

    scope :promoted, ->(n) { where(promoted: true).order('updated_at desc').limit(n) }
    scope :newer, ->(date) { where('release_date > ?', date).order('release_date desc') }
    scope :older, ->(date) { where('release_date < ?', date).order('release_date desc') }

    def title
      self[:title].strip
    end

    def short_title
      return unless title
      # Truncate title e.g. for slider, value was determined experimentally
      title.truncate(40, omission: '…')
    end

    def display_date
      d = date || release_date
      d.strftime('%Y-%m-%d') if d
    end

    def released_on_event_day?
      date && date.to_date === release_date.to_date
    end

    def poster_url
      File.join(Settings.static_url, conference.images_path, poster_filename).freeze if poster_filename
    end

    def short_description
      return unless description
      description.truncate(140)
    end

    def thumb_url
      if thumb_filename_exists?
        File.join(Settings.static_url, conference.images_path, thumb_filename).freeze
      else
        conference.logo_url.freeze
      end
    end

    def tags
      self[:tags].compact.collect(&:to_s).collect(&:strip).map!(&:freeze)
    end

    def has_translation
      self.recordings.select { |x| x.languages.length > 1 }.present?
    end

    def filetypes(mime_type)
      self.recordings.by_mime_type(mime_type)
        .map { |x| [x.filetype, x.display_filetype] }
        .uniq.to_h.sort
    end

    # used by player
    def videos_sorted_by_language
      self.recordings.video.sort_by { |x| (x.language == self.original_language ? 0 : 2) + (x.html5 ? 0 : 1) }
    end

    # used for the hd and sd download buttons
    def video_for_download(filetype, high_quality: true)
      self.recordings.video_without_slides
        .select { |x| x.filetype == filetype && x.high_quality == !!high_quality }
        .sort_by { |x| x.html5 ? 1 : 0 }
        .first
    end

    def audio_recordings_for_download(filetype)
      self.recordings.audio
        .select { |x| x.filetype == filetype }
        .sort_by { |x| x.language == self.original_language ? '' : x.language }
        .map { |x| [x.language, x] }
        .to_h
    end

    def audio_recording
      audio_recordings = recordings.original_language.where(mime_type: MimeType::AUDIO)
      return if audio_recordings.empty?
      seen = Hash[audio_recordings.map { |r| [r.mime_type, r] }]
      MimeType::AUDIO.each { |mt| return seen[mt] if seen.key?(mt) }
      seen.first[1]
    end

    def slides_for_download(filetype)
      self.recordings.slides
        .select { |x| x.filetype == filetype }
        .sort_by { |x| x.language == self.original_language ? '' : x.language }
        .map { |x| [x.language, x] }
        .to_h
    end

    def slide
      slides = recordings.slides
      return if slides.empty?
      seen = Hash[slides.map { |r| [r.mime_type, r] }]
      MimeType::SLIDES.each { |mt| return seen[mt] if seen.key?(mt) }
      seen.first[1]
    end

    def preferred_recording(order: MimeType::PREFERRED_VIDEO)
      video_recordings = recordings.html5.video
      return if video_recordings.empty?
      seen = Hash[video_recordings.map { |r| [r.mime_type, r] }]
      order.each { |mt| return seen[mt] if seen.key?(mt) }
      seen.first[1]
    end

    # @return [Array(Recording)]
    def by_mime_type(mime_type: 'video/mp4')
        recordings.by_mime_type(mime_type).first.freeze
    end

    def related_event_ids(n)
      return conference.events.ids unless metadata.key?('related')
      metadata['related'].keys.shuffle[0..n-1]
    end

    def next_from_conference(n)
      events = conference.events.to_a
      pos = events.index(self) + 1
      pos = 0 if pos >= events.count
      events[pos..pos+n-1]
    end

    def playlist
      related_ids = related_event_ids(20)
      [self] + Event.where(id: related_ids).includes(:conference).to_a
    end

    def relive_present?
      return unless conference.metadata['relive'].present?
      conference.metadata['relive'].any? { |r| r['guid'] == guid }
    end

    def relive
      conference.metadata['relive']&.first { |r| r['guid'] == guid }
    end

    private

    def thumb_filename_exists?
      return if thumb_filename.blank?
      true
    end
  end
end
