require 'active_support/concern'

module VideopageBuilder
  extend ActiveSupport::Concern

  included do

    def save_index_vgallery(conference)
      path = File.join MediaBackend::Application.config.folders[:webgen_base_dir], conference.webgen_location
      index_file = File.join(path, "index.vgallery")
      data = build_index_vgallery(conference)
      File.open(index_file, "w") do |f|
        f.puts data.sort.to_yaml, '---'
      end
    end

    def save_videopage(conference, event)
      path = File.join MediaBackend::Application.config.folders[:webgen_base_dir], conference.webgen_location

      page = build_videopage(conference, event)
      return if page.nil?

      data = page[:data] 
      blocks = page[:blocks]
      page_file = File.join(path, page[:filename])

      FileUtils.mkdir_p path
      File.open(page_file, "w") do |f|
        f.puts data.to_yaml, '---'
        f.puts blocks.join("\n---\n") if blocks
      end
      page_file
    end

    private

    def build_index_vgallery(conference)
      data = {
        'title'  => conference.title || conference.acronym,
        'folder' => conference.webgen_location,
        'inMenu' => 'false'
      }
      # if conference.logo
      #   data['thumbPath'] = conference.logo
      # end
      data
    end

    MAPPINGS = {
        'application/ogg' => :audioPath,
        'audio/mpeg'      => :audioPath,
        'audio/x-wav'     => :audioPath,
        'video/mp4'       => :h264Path,
        'video/webm'      => :webmPath,
        'video/ogg'       => :ogvPath
    }

    # see /README.videopage
    def build_videopage(conference, event)
      event_info = event.event_info
      if event_info.nil?
        raise "missing event info"
        return
      end

      data = {
        'tags' => [conference.acronym],
        'link' => 'http://ccc.de'
      }

      data['title'] = event.title
      data['folder'] =  conference.webgen_location
      data['thumbPath'] =  File.join(conference.get_images_path, event.gif_filename)
      data['splashPath'] =  File.join(conference.get_images_path, event.poster_filename)
      data['date'] = event_info.date
      data['persons'] = event_info.persons if event_info.persons.size > 0
      data['subtitle'] = event_info.subtitle if event_info.subtitle
      data['link'] = event_info.link
      data['tags'] += event_info.tags

      # obsolete?
      #'orgPath' => sprintf(@evmeta.original_video_url_format, file)

      # TODO parse aspect_ratio
      if conference.aspect_ratio and conference.aspect_ratio == '16:9'
        data['flvWidth'] = '640'
        data['flvHeight'] = '360'
      end

      # find recordings
      event.recordings.each { |r|
        if MAPPINGS.include? r.mime_type
          key = MAPPINGS[r.mime_type]
          data[key] = r.get_recording_path
        end
        # obsolete:'filePath' =>  File.join(@evmeta.video_path, file) + '.'+@evmeta.video_extension,
      }

      filename = event_info.slug + '.page'
      filename.gsub!(/ /, '_')
      {filename: filename, data: data, blocks: [ event_info.description ]}
    end

  end

end
