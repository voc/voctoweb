module CheckStorage

  # check if all recordings from the database exist in the filesystem
  def check_videos_exist_on_disk
    missing = Recording.all.select { |r| not File.readable? r.get_recording_path }
    CheckStorage.check_videos_exist_on_disk.select do |r| 
      if File.readable? r.get_recording_path.gsub(/_h264\./, '.')
        r.filename.gsub!(/_h264\./, '.')
        r.save
      end
    end
  end

  # check if all recordings in the filesystem are represented in the db
  def check_videos_in_db
  end

  # check if database is linking to removed files
  def check_media_exists_on_disk
    missing_logos = Conference.all.select { |c| not File.readable? c.get_logo_path }
    missing_images = Event.all.select { |e| 
      not File.readable? e.get_gif_path or
        not File.readable? e.get_poster_path or
        not File.readable? e.get_thumb_path
    }
    missing_logos & missing_images
  end

  # check if files were not imported to db
  def check_media_exists_in_db
  end

  def check_webm_missing
    Event.where(<<-SQL)
      not exists (SELECT null from recordings where events.id = recordings.event_id and recordings.mime_type='video/webm')
    SQL
  end

  def check_recording_dupes
    counts = Recording.select('recordings.id').group('event_id').group('folder').group('filename').count
    dupes = counts.select { |arr, count| count > 1 }

    return dupes

    # delete duplicate recordings
    #dupes.map { |arr, count| 
    #  recordings = Recording.where event_id: arr[0], folder: arr[1], filename: arr[2] 
    #  recordings[1..-1].each { |r| r.delete }
    #}
  end

  module_function :check_videos_exist_on_disk,
    :check_media_exists_on_disk, 
    :check_webm_exists, 
    :check_recording_dupes
end
