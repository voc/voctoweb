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

  def self.save_videopage(conference, event)
    path = conference.get_webgen_location
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
    Rails.logger.info "Built videopage file #{page_file}"
    page_file
  end

  private

  def self.build_index_vgallery(conference)
    data = {
      'title'  => conference.title || conference.acronym,
      'folder' => conference.webgen_location,
      'inMenu' => false
    }
    # if conference.logo
    #   data['thumbPath'] = conference.logo
    # end
    data
  end

  # see /README.videopage
  def self.build_videopage(conference, event)
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
    data['thumbPath'] = conference.get_images_url(event.gif_filename)
    data['splashPath'] =  conference.get_images_url(event.poster_filename)
    data['date'] = event_info.date
    data['persons'] = event_info.persons if event_info.persons.size > 0
    data['subtitle'] = event_info.subtitle if event_info.subtitle
    data['link'] = event_info.link
    data['tags'] += event_info.tags
    data['tags'] = data['tags'].join(',')

    # obsolete?
    #'orgPath' => sprintf(@evmeta.original_video_url_format, file)

    # TODO parse aspect_ratio
    if conference.aspect_ratio and conference.aspect_ratio == '16:9'
      data['flvWidth'] = 640
      data['flvHeight'] = 360
    end

    # find recordings
    mappings = {
      'application/ogg' => 'audioPath',
      'audio/mpeg'      => 'audioPath',
      'audio/x-wav'     => 'audioPath',
      'video/mp4'       => 'h264Path',
      'video/webm'      => 'webmPath',
      'video/ogg'       => 'ogvPath'
    }

    event.recordings.each { |r|
      if mappings.include? r.mime_type
        key = mappings[r.mime_type]
        data[key] = conference.get_recordings_url(r.get_recording_webpath)
        # FIXME still required by webgen
        data['orgPath'] = data[key]
      end
      # obsolete:'filePath' =>  File.join(@evmeta.video_path, file) + '.'+@evmeta.video_extension,
    }

    filename = event_info.slug + '.page'
    filename.gsub!(/ /, '_')
    {filename: filename, data: data, blocks: [ event_info.description ]}
  end

end
