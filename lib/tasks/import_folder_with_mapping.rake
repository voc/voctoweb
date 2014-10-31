namespace :media do

  desc "import videos from one folder into the database with less auto deduction. each line of the input-file should contain a slug-refix for finding the event and a filename"
  task :import_folder_with_mapping => :environment do |t,args|

    @list = ENV['list']
    @folder = ENV['folder'] # existing folder in CDN, below conference.recordings_path
    @mime_type = ENV['mime_type']
    @width = ENV['width']
    @height = ENV['height']

    if not @list or not File.readable? @list or @folder.nil? or @mime_type.nil?
      puts "Usage: rake media:import_folder list=videos.lst folder=mp4 mime_type=video/mp4 width=320 height=240"
      exit
    end

    ActiveRecord::Base.transaction do
      File.open(@list).each_line do |line|
        line.chomp!
        if line.length == 0
          next
        end

        (slug_prefix, filename) = line.split("\t", 2).map{ |s| s.strip }
        filename = File.basename filename

        events = Event.where("slug like :prefix", prefix: "#{slug_prefix}%")

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
          folder: @folder, mime_type: @mime_type, width: @width, height: @height

        event.recordings << recording

        puts "#{recording.get_recording_path} added to #{event.slug}"
      end
    end

  end
end
