namespace :media do

  desc "import one video for a specific slug"
  task :import_video => :environment do |t,args|

    @filename = ENV['filename']
    @slug = ENV['slug']
    @folder = ENV['folder'] # existing folder in CDN, below conference.recordings_path
    @mime_type = ENV['mime_type']
    @width = ENV['width']
    @height = ENV['height']

    if @filename.nil? or @slug.nil? or @folder.nil? or @mime_type.nil?
      puts "Usage: rake media:import_video filename=123_video.mp4 slug=123_video folder=mp4 mime_type=video/mp4 width=320 height=240"
      exit
    end

    event = Event.where(slug: @slug).first
    unless event
      test = @slug.gsub(/[_-]/, '.')
      event = Event.select { |event| event.slug =~ /\A#{test}/i }.first
    end
    unless event
      STDERR.puts "### not found #{@filename} = #{@slug}" 
      next
    end

    recording = Recording.new filename: @filename, event: event, state: 'downloaded',
      folder: @folder, mime_type: @mime_type, width: @width, height: @height

    event.recordings << recording

    puts "#{recording.get_recording_path} added to #{event.slug}"

  end
end
