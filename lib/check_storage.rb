module CheckStorage

  class DatabaseStorageChecker

    # check if all recordings from the database exist in the filesystem
    def check_videos_exist_on_disk
    end

    # check if all recordings in the filesystem are represented in the db
    def check_videos_in_db
    end

    # check if database is linking to removed files
    def check_media_exists_on_disk
    end

    # check if files were not imported to db
    def check_media_exists_in_db
    end

  end

  def check_recording_dupes
    counts = Recording.select('recordings.id').group('event_id').group('folder').group('filename').count
    dupes = counts.select { |arr, count| count > 1 }

    dupes.map { |arr, count| 
      recordings = Recording.where event_id: arr[0], folder: arr[1], filename: arr[2] 
      recordings[1..-1].each { |r| r.delete }
    }
  end

  module_function :check_recording_dupes
end
