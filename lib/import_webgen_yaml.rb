require 'yaml'
require 'ostruct'

module Import
  class WebgenYAML

    CONFERENCE_DATA = {
      blinkenlights: 'blinkenlights',
      camp2003:      'conferences/camp2003',
      camp2007:      'conferences/camp2007',
      camp2011:      'conferences/camp2011',
      eh2010:        'conferences/eh2010',
      froscon2010:   'conferences/froscon/2010',
      froscon2011:   'conferences/froscon/2011',
      froscon2013:   'conferences/froscon/2013',
      hal2001:       'conferences/hal2001',
      har2009:       'conferences/har2009',
      mrmcd0x8:      'conferences/mrmcd/mrmcd0x8',
      mrmcd101b:     'conferences/mrmcd/mrmcd101b',
      mrmcd110b:     'conferences/mrmcd/mrmcd110b',
      mrmcd111b:     'conferences/mrmcd/mrmcd111b',
      sigint09:      'conferences/sigint09',
      sigint10:      'conferences/sigint10',
      sigint12:      'conferences/sigint12',
      sigint13:      'conferences/sigint13',
      :'17c3' =>      'congress/2000',
      :'18c3' =>      'congress/2001',
      :'19c3' =>      'congress/2002',
      :'20c3' =>      'congress/2003',
      :'21c3' =>      'congress/2004',
      :'22c3' =>      'congress/2005',
      :'23c3' =>      'congress/2006',
      :'24c3' =>      'congress/2007',
      :'25c3' =>      'congress/2008',
      :'26c3' =>      'congress/2009',
      :'27c3' =>      'congress/2010',
      :'28c3' =>      'congress/2011',
      :'29c3' =>      'congress/2012',
      :'30c3' =>      'congress/2013',
      :'Freiheit_statt_Angst_Demo' => 'events/Freiheit_statt_Angst_Demo',
      :'Netzzensur_Demo' => 'events/Netzzensur_Demo',
      :'Panoptische_Prinzip' => 'events/Panoptische_Prinzip',

      # external:
      #:'Fingerabdruck_Hack' => 'events/Fingerabdruck_Hack',
      #:'Trusted_Computing' => 'events/Trusted_Computing',
      #c4: 'regional/c4',
      #cccmz: 'regional/cccmz',
    }

    CONFERENCE_VIDEOS = {
      blinkenlights: 'blinkenlights',
      camp2003:      'events/camp2003',
      camp2007:      'events/camp2007',
      camp2011:      'events/camp2011',
      eh2010:        'events/eh2010',
      froscon2010:   'events/froscon/2010',
      froscon2011:   'events/froscon/2011',
      froscon2013:   'events/froscon/2013',
      hal2001:       'events/hal2001',
      har2009:       'events/har2009',
      mrmcd0x8:      'events/mrmcd/mrmcd0x8',
      mrmcd101b:     'events/mrmcd/mrmcd101b',
      mrmcd110b:     'events/mrmcd/mrmcd110b',
      mrmcd111b:     'events/mrmcd/mrmcd111b',
      sigint09:      'events/sigint09',
      sigint10:      'events/sigint10',
      sigint12:      'events/sigint12',
      sigint13:      'events/sigint13',
      :'17c3' =>      'congress/2000',
      :'18c3' =>      'congress/2001',
      :'19c3' =>      'congress/2002',
      :'20c3' =>      'congress/2003',
      :'21c3' =>      'congress/2004',
      :'22c3' =>      'congress/2005',
      :'23c3' =>      'congress/2006',
      :'24c3' =>      'congress/2007',
      :'25c3' =>      'congress/2008',
      :'26c3' =>      'congress/2009',
      :'27c3' =>      'congress/2010',
      :'28c3' =>      'congress/2011',
      :'29c3' =>      'congress/2012',
      :'30c3' =>      'congress/2013',
      :'Freiheit_statt_Angst_Demo' => 'events/freiheit_statt_angst_demo_Sep2009',
      :'Netzzensur_Demo' => 'events/netzzensur_demo2002',
      :'Panoptische_Prinzip' => 'contributors/koeln/DasPanoptischePrinzip (2007)',
    }

    def initialize(dir)
      @dir = dir
      @conference_cache = {}
      @external_videos = File.open('videos.lst').readlines.map { |line| line.chomp!  }
    end

    def import
      ActiveRecord::Base.transaction do
        import_conferences # folders
      end
      ActiveRecord::Base.transaction do
        import_events      # pages
      end
    end

    private

    def import_conferences
      CONFERENCE_DATA.each do |acronym, folder|
        conference_folder = File.join @dir, folder
        conference = get_conference(acronym, conference_folder)

        images_path_finder = BasePathFinder.new
        Dir[File.join conference_folder, '**/*.page'].each do |path|
          page = YAML.load_file( path )

          images_path_finder << File.dirname(page['thumbPath'])
        end
        conference.recordings_path = CONFERENCE_VIDEOS[conference.acronym.to_sym]
        conference.images_path = images_path_finder.base.sub(%r{^/media/},'') # from config
        conference.webgen_location = folder

        @conference_cache[acronym] = conference
        conference.save 
      end
    end

    def import_events
      CONFERENCE_DATA.each do |acronym, folder|
        conference = @conference_cache[acronym]
        conference_folder = File.join @dir, folder
        Dir[File.join conference_folder, '**/*.page'].each do |path|
          docs = load_videopage(path)
          event = import_event(conference, path, docs.page, docs.description)
          import_recordings(conference, event, docs.page)
        end
      end
    end

    def load_videopage(file)
      lines = File.open(file, 'r:UTF-8' ).readlines
      # extract blocks
      filedata = []
      block = []
      lines.each { |l|
        if l.match(/^---\s*$/)
          filedata << block unless block.empty?
          block = []
        else
          block << l
        end
      }
      filedata << block unless block.empty?

      # parse blocks
      t = OpenStruct.new
      t.page = YAML.load(filedata[0].join)
      t.text = filedata[1..-1].join
      t
    end


    def import_event(conference, path, page, description)
      test = Event.where(gif_filename: File.basename(page['thumbPath']))
      if test.count > 0
        #STDERR.puts "updating existing event in db: #{page['thumbPath']}"
        event = test.first
      else
        event = Event.new
      end
      # TODO missing sometimes?
      event.poster_filename = get_image(conference.images_path, page['splashPath'])
      event.subtitle = page['subtitle']
      event.persons = get_arr(page['persons'])
      event.date = page['date']
      event.link = page['link']
      event.tags = get_arr(page['tags'])
      event.thumb_filename = get_image(conference.images_path, page['thumbPath'].sub(/gif$/, 'jpg'))
      event.gif_filename = get_image(conference.images_path, page['thumbPath'])
      event.title = page['title']
      event.description = description
      event.conference_id = conference.id
      event.guid = 'import-' + SecureRandom.hex(9)
      event.slug = File.basename(path).sub(%r'.page$', '')
      raise "invalid event #{event.errors.messages}" unless event.valid?
      event.save
      event
    end

    def get_image(prefix, path)
      if path.present?
        path.sub(/^\/media\//, '').sub(%r{^#{Regexp.quote prefix}}, '').sub(/^\//, '')
      else
        ""
      end
    end

    def get_arr(p)
      if p.present?
        p.split(/,/)
      else
        []
      end
    end

    def import_recordings(conference, event, page)
      paths =  get_recordings(page)
      #p paths

      paths.each { |path|
        path = path.sub(%r{^#{Regexp.quote conference.recordings_path}}, '').sub(/^\//, '')
        filename = File.basename path
        folder = File.dirname path
        test = Recording.where filename: filename, folder: folder
        if test.count > 0
          #STDERR.puts "recording exists for #{folder} / #{filename}!?"
          # skip
        else
          recording = Recording.new
          recording.event_id = event.id
          recording.filename = filename
          recording.folder = folder
          recording.mime_type = get_mime_type path
          recording.length = page['videoLength']
          recording.size = page['videoSize']
          # TODO not needed?
          #recording.original_url = page['orgPath']
          recording.state = :downloaded
          raise "invalid recording #{recording.errors.messages}" unless recording.valid?
          recording.save
        end

      }
    end

    def get_mime_type(path)
      types = {
        mp4: 'video/mp4',
        ogg: 'audio/ogg',
        ogv: 'video/ogg',
        ebm: 'video/webm',
        mp3: 'audio/mpeg'
      }
      types[path[-3..-1].to_sym]
    end

    def get_conference(acronym, path)
      conference = create_conference(acronym, path)
      conference
    end

    def create_conference(acronym, path)
      conference = Conference.where(acronym: acronym).first
      unless conference.present?
        conference = Conference.new
        conference.acronym = acronym.to_s
        import_vgallery(conference, path)
      end
      conference
    end

    def import_vgallery(conference, path)
      index = File.join(path, 'index.vgallery')
      if File.readable? index
        index_data = YAML.load_file index
        conference.title = index_data['title']
        conference.logo = index_data['thumbPath']
      else
        raise "Vgallery not found: #{path}"
      end
    end

    def get_recordings(page)
      result = []
      recordings = %w{webmPath h264Path ogvPath flvPath audioPath} & page.keys
      recordings.each { |key|
        path = page[key].sub(%r{^/media/}, '').sub(%r{^http://cdn.media.ccc.de/}, '')
        # TODO skip potentially external videos for now (import from videos_linked_event.lst later)
        result << path unless @external_videos.include? path
      }
      result
    end

    class BasePathFinder
      def initialize
        @paths = []
      end
      attr_reader :paths

      def <<(a)
        @paths << a
      end

      def base
        paths = @paths.sort.uniq
        path = paths.min
        r = ""
        path.split('').each_with_index { |c,i|
          r += c if paths.all? { |p| p[i] == c }
        }
        r.sub(/\/$/, '')
      end

    end


  end
end

=begin

  'h264Path' =>  File.join(evmeta.video_url, file) + '.'+evmeta.video_extension,
  'filePath' =>  File.join(evmeta.video_path, file) + '.'+evmeta.video_extension,
  'thumbPath' => File.join(evmeta.media_url, thumbPath),
  'splashPath' => File.join(evmeta.media_url, thumbPath).gsub(/\.gif$/, '_preview.jpg'),
  'orgPath' => sprintf(evmeta.original_video_url_format, file),

  'title' => ev[:title],
  'paths' => paths,
  'link' => sprintf(evmeta.original_about_url_format, id),
  'tags' => ev[:tags],
  'folder' => evmeta.folder,
  'date' => ev[:date],
  'persons' => ev[:persons],

        cdnURL
        podcastXML
     59 aspectRatio        conference.aspect_ratio
     95 ogvPath            recording.filename, recording.mime_type
    494 flvHeight
    494 flvWidth
    587 filePath
    809 flvPath
    931 splashPath         =event.poster_filename
    979 webmPath           recording
   1047 subtitle           =event.subtitle
   1072 audioPath          recording
   1261 persons            =event.persons
   1599 h264Path           recording
   1693 videoHeight
   1693 videoLength        =recording.length
   1693 videoSize          =recording.size
   1694 videoWidth
   1809 folder
   1811 date               =event.date
   1811 link               =event.link
   1811 orgPath            =recording.original_url
   1811 tags               =event.tags
   1811 thumbPath          =event.thumb_filename, event.gif_filename
   1811 title              =event.title
                           =event.description
                           =recording.state
        folder name        =conference.acronym
                           =conference.recordings_path
                           =conference.images_path
                           =conference.webgen_location
        index.vgallery     =conference.title

=end
