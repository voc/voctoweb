require 'time'

# = Description
#
# generate iTunes store feed
module PodcastGenerator

  def self.generate(conference)
    rss = PodcastGenerator::UpdatesITS.new
    rss.load_config
    rss.config['output_file'] = File.join(conference.get_webgen_location, 'podcast.xml')
    rss.config['channel_title'] = "Chaos Computer Club - #{conference.title}"
    rss.generate_conference conference
  end


  class UpdatesITS
    require 'rss/2.0'
    require 'rss/itunes'
    require 'rss/maker'
    require 'rss/content'

    def initialize
      @config = {}
    end
    attr_reader :config
    attr_writer :config

    def load_config
      filename = File.join(Rails.root, 'config', 'podcast_template.yml')
      raise "failed to load config #{filename}" unless File.readable? filename
      @config = YAML.load File.open filename
    end

    def generate_conference(conference)
      if File.readable?(@config['output_file'])
        File.delete(@config['output_file'])
      end

      rss = create_rss(conference)

      begin
        f = File.open(@config['output_file'], 'w')
        f.puts rss
      ensure
        f.close if f
      end
    end

    private

    def create_rss(conference)
      seen = {}
      rss = RSS::Maker.make("2.0") do |maker|

        create_channel(maker)

        conference.events.each { |event|
          next unless File.exists?(event.get_videopage_path)
          next if seen.has_key?(event.guid)
          seen[event.guid] = 1

          recordings = event.recordings_by_mime_type
          recording = get_preferred_recording(recordings)
          next if recording.nil?
          link = conference.get_recordings_url(recording.get_recording_webpath)

          # create item
          item = maker.items.new_item
          item.title = get_item_title(conference, event)

          item.link = link
          item.itunes_keywords = event.try(:tags)
          item.guid.content = link
          item.guid.isPermaLink = true
          item.dc_identifier = event.guid

          # FIXME decode, redcloth, whatever
          description = get_item_description(event)
          item.description = description
          item.itunes_summary = description
          item.itunes_explicit = "No"
          item.pubDate = event.created_at.to_s

          item.itunes_subtitle = event.subtitle if event.subtitle.present?
          item.itunes_author = event.persons.join(', ') if event.persons.present?
          item.pubDate = event.date.to_s if event.date.present?

          # TODO video image possible? ( data['thumbPath'] )
          item.enclosure.url = link
          item.enclosure.length = 0
          item.enclosure.type = recording.mime_type
        }

      end
      rss
    end

    def get_preferred_recording(recordings, order=%w{video/webm video/mp4 video/ogg video/flv})
      return if recordings.empty?
      order.each { |mt|
        return recordings[mt] if recordings.has_key?(mt)
      }
      recordings.first[1]
    end

    def create_channel(maker)
      maker.channel.title = @config['channel_title']
      maker.channel.link =  @config['base_url']
      maker.channel.description = @config['channel_description']
      maker.channel.copyright = "mostly cc-by-nc"
      maker.channel.language = "en-us, de-de"
      maker.channel.lastBuildDate = Time.now

      # see http://www.apple.com/itunes/podcasts/specs.html#category
      #category = maker.channel.itunes_categories.new_category
      #category.text = "Technology"
      #category.new_category.text = "Technology"
      maker.channel.itunes_categories.new_category.text = "Technology"

      # TODO png/jpg?
      maker.image.url = @config['logo_image']
      maker.image.title = @config['channel_title']
      maker.channel.itunes_author = @config['channel_owner']
      maker.channel.itunes_owner.itunes_name = @config['channel_owner']
      maker.channel.itunes_owner.itunes_email='media@koeln.ccc.de'
      maker.channel.itunes_keywords = @config['channel_keywords']
      maker.channel.itunes_subtitle = @config['channel_subtitle']
      maker.channel.itunes_summary = @config['channel_summary']

      # TODO different image?
      maker.channel.itunes_image = @config['logo_image']
      maker.channel.itunes_explicit = "No"
    end

    def get_item_description(event)
      description = []
      description << event.description or event.subtitle

      link = event.link
      description << "about this event: #{link}\n" if link

      # file = 'src/browse/bla.page'
      url = @config['base_url'] + event.get_videopage_filename
      url.gsub!(/page$/, 'html')
      description << "event on media: #{url}\n"

      description.join
    end

    def get_item_title(conference, event)
      title = ''
      if conference.title.present? 
        title = conference.title
      elsif conference.acronym.present?
        title = conference.acronym
      end
      title += ": "
      if event.title
        title += event.title
      else
        title += event.get_videopage_filename[0..-6]
      end
      title
    end

    def get_item_event_id(path, pattern)
      m = path.match(pattern)
      return if m.nil?
      m[1]
    end
  end
end

