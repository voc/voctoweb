namespace :media do

  desc "import videos from one folder into the database"
  task :import_folder => :environment do |t,args|

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
        filename = File.basename line
        slug = File.basename line, '.*'

        event = Event.where(slug: slug).first
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
