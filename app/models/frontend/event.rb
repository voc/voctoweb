module Frontend
  class Event < ::Event
    belongs_to :conference, class_name: Frontend::Conference
    has_many :recordings, class_name: Frontend::Recording

    scope :promoted, ->(n) { where(promoted: true).order('updated_at desc').limit(n) }
    scope :recent, ->(n) { order('release_date desc').limit(n) }
    scope :newer, ->(date) { where('release_date > ?', date).order('release_date desc') }
    scope :older, ->(date) { where('release_date < ?', date).order('release_date desc') }

    def title
      self[:title].strip
    end

    def poster_url
      File.join(Settings.staticURL, 'media', conference.images_path, poster_filename) if poster_filename
    end

    def thumb_url
      File.join Settings.staticURL, 'media', conference.images_path, thumb_filename
    end

    def tags
      self[:tags].compact.collect(&:strip)
    end

    def linked_persons_text
      if persons.length == 0
        'n/a'
      elsif persons.length == 1
        linkify_persons(persons)[0]
      else
        persons = linkify_persons(self.persons)
        persons = persons[0..-3] + [persons[-2..-1].join(' and ')]
        persons.join(', ')
      end
    end

    def linkify_persons(persons)
      persons.map { |person| '<a href="/search/?q=' + CGI.escapeHTML(CGI.escape(person)) + '">' + CGI.escapeHTML(person) + '</a>' }
    end

    def persons_icon
      if persons.length <= 1
        'fa-user'
      else
        'fa-group'
      end
    end

    def preferred_recording(order: MimeType::PREFERRED_VIDEO, mime_type: nil)
      recordings = recordings_by_mime_type
      return if recordings.empty?
      order.each do |mt|
        return recordings[mt] if recordings.key?(mt)
      end
      recordings.first[1]
    end

    # @return [Array(Recording)]
    def by_mime_type(mime_type: 'video/mp4')
      recordings.downloaded.by_mime_type(mime_type).first
    end

    private

    def recordings_by_mime_type
      Hash[recordings.downloaded.map { |r| [r.mime_type, r] }]
    end
  end
end
