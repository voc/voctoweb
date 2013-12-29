module VideopageBuilder

  def self.save_index_vgallery(conference)
    path = conference.get_webgen_location
    FileUtils.mkdir_p path

    index_file = File.join(path, "index.vgallery")
    data = build_index_vgallery(conference)
    File.open(index_file, "w") do |f|
      f.puts data.to_yaml, '---'
    end
    Rails.logger.info "Built videopage index file #{index_file}"
  end

  def self.remove_videopage(conference, event)
    path = conference.get_webgen_location
    page_file = event.get_videopage_path
    if File.readable? page_file
      FileUtils.remove_file page_file
    end
  end

  def self.save_videopage(conference, event)
    page = build_videopage(conference, event)
    return if page.nil?

    data = page[:data] 
    blocks = page[:blocks]

    if not File.directory? conference.get_webgen_location
      FileUtils.mkdir_p conference.get_webgen_location
    end
    page_file = event.get_videopage_path
    File.open(page_file, "w") do |f|
      f.puts data.to_yaml, '---'
      f.puts blocks.join("\n---\n") if blocks
    end
    Rails.logger.info "Built videopage file #{page_file}"
    page_file
  end

  private

  def self.build_index_vgallery(conference)
    data = {
      'title'  => conference.title || conference.acronym,
      'folder' => conference.webgen_location,
    }
    # if conference.logo
    #   data['thumbPath'] = conference.logo
    # end
    data
  end

  # see /README.videopage
  def self.build_videopage(conference, event)

    data = {
      'tags' => [conference.acronym],
      'link' => 'http://ccc.de'
    }

    data['title'] = event.title
    data['folder'] =  conference.webgen_location
    data['thumbPath'] = conference.get_images_url(event.gif_filename)
    data['splashPath'] =  conference.get_images_url(event.poster_filename)
    data['podcastXML'] =  File.join conference.webgen_location, 'podcast.xml'
    data['cdnURL'] =  File.join MediaBackend::Application.config.cdnURL, conference.recordings_path

    description = ""
    event_info = event.event_info
    unless event_info.nil?
      description = event_info.description
      data['date'] = event_info.date
      data['persons'] = event_info.persons if event_info.persons.size > 0
      data['subtitle'] = event_info.subtitle if event_info.subtitle
      data['link'] = event_info.link
      data['tags'] += event_info.tags
    end
    data['tags'] = data['tags'].join(',')

    if conference.aspect_ratio
      parse_aspect_ratio(conference.aspect_ratio, data)
    end

    find_recordings(conference, event.recordings, data)

    {data: data, blocks: [ description ]}
  end

  def self.find_recordings(conference, recordings, data)
    mappings = {
      'application/ogg' => 'audioPath',
      'audio/ogg'       => 'audioPath',
      'audio/mpeg'      => 'audioPath',
      'audio/x-wav'     => 'audioPath',
      'video/mp4'       => 'h264Path',
      'video/webm'      => 'webmPath',
      'video/ogg'       => 'ogvPath'
    }

    recordings.each { |r|
      if mappings.include? r.mime_type
        key = mappings[r.mime_type]
        data[key] = conference.get_recordings_url(r.get_recording_webpath)
        # FIXME still required by webgen - use last video
        data['orgPath'] = data[key] if r.mime_type.match(/video/)
      end
    }

  end

  def self.parse_aspect_ratio(aspect_ratio, data)
    data['aspectRatio'] = aspect_ratio
    if aspect_ratio == '16:9'
      data['flvWidth'] = 640
      data['flvHeight'] = 360
    else
      data['flvWidth'] = 400
      data['flvHeight'] = 300
    end
  end

end
