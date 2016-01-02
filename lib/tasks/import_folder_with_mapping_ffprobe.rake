namespace :media do
  desc 'import recordings from one folder to existing events. Each line of the input-file should contain a slug-prefix for finding the event and a filename. Uses ffprobe.'
  task :import_folder_with_mapping_ffprobe => :environment do |_t, _args|
    @list = ENV['list']
    @folder = ENV['folder'] # existing folder in CDN, below conference.recordings_path
    @mime_type = ENV['mime_type']

    if not @list or not File.readable? @list or @folder.nil? or @mime_type.nil?
      puts 'Usage: rake media:import_folder list=videos.lst folder=mp4 mime_type=video/mp4'
      exit
    end

    ActiveRecord::Base.transaction do
      File.open(@list).each_line do |line|
        line.chomp!
        next if line.length == 0

        (slug_prefix, filename) = line.split("\t", 2).map(&:strip)
        filename = File.basename filename

        events = Event.where('slug like :prefix', prefix: "#{slug_prefix}%")

        if events.count > 1
          STDERR.puts "### slug-prefix #{slug_prefix} does not uniquely match an event"
          next
        end

        event = events.first
        unless event
          STDERR.puts "### not found #{filename}"
          next
        end

        recording = Recording.new filename: filename, event: event, state: 'downloaded',
          folder: @folder, mime_type: @mime_type

        if event.recordings.any? { |r| r.get_recording_path == recording.get_recording_path }
          STDERR.puts "### skip existing recording for #{filename}"
          next
        end

        fill_from_ffprobe(recording)

        event.recordings << recording

        puts "#{recording.get_recording_path} added to #{event.slug}"
      end
    end
  end

  def fill_from_ffprobe(recording)
    unless File.readable? recording.get_recording_path
      fail "### file not found on disk #{recording.get_recording_path}"
    end
    format = `ffprobe -v error -show_format "#{recording.get_recording_path}"`
    recording.length = format.match(/duration=(\d*)/)[1]
    format = `ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width #{recording.get_recording_path}`
    recording.width = format.match(/width=(.*)$/)[1]
    recording.height = format.match(/height=(.*)$/)[1]
  end
end
