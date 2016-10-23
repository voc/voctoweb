require 'pathname'

namespace :db do
  namespace :import do
    desc 'Import Data from another instances\' public API'
    task :conference, [:uri] => [:environment] do |t, args|

      unless args[:uri]
        fail 'specify API-URL to read from: `rake db:import:conference[https://api.media.ccc.de/public/conferences/78]`'
      end

      uri = URI(args[:uri])
      response = Net::HTTP.get(uri)
      json = JSON.parse(response, :symbolize_names => true)

      ActiveRecord::Base.transaction do
        conference_data = json.extract! :acronym, :slug, :title, :aspect_ratio, :schedule_url, :updated_at

        cdn_pathname = Pathname.new(Settings.cdn_url)
        conference_data[:recordings_path] = Pathname(json[:recordings_url]).relative_path_from(cdn_pathname).to_s

        static_pathname = Pathname.new(Settings.static_url)
        conference_data[:images_path] = Pathname(json[:images_url]).relative_path_from(static_pathname).to_s

        image_pathname = static_pathname.join(conference_data[:images_path])
        conference_data[:logo] = Pathname(json[:logo_url]).relative_path_from(image_pathname).to_s

        c = Conference.create(conference_data)
        puts "imported conference #{c.display_name}"

        json[:events].each do |event|
          event_data = event.extract! :guid, :title, :subtitle, :slug, :link, :description, :original_language, :date, :release_date, :updated_at, :tags, :persons

          event_data[:thumb_filename] = Pathname(event[:thumb_url]).relative_path_from(image_pathname).to_s
          event_data[:poster_filename] = Pathname(event[:poster_url]).relative_path_from(image_pathname).to_s

          event_data[:conference] = c

          e = Event.create(event_data)
          puts "imported event #{e.display_name}"


          uri = URI(event[:url])
          response = Net::HTTP.get(uri)
          eventjson = JSON.parse(response, :symbolize_names => true)

          eventjson[:recordings].each do|recording|
            recording_data = recording.extract! :size, :length, :mime_type, :updated_at, :filename, :state, :folder, :width, :height, :language, :high_quality

            # fixme not yet exposed via public api
            # see https://github.com/voc/voctoweb/issues/122
            recording_data[:html5] = true

            recording_data[:event] = e

            r = Recording.create(filename)
            puts "imported recording #{r.mime_type}"
          end

        end
      end

    end
  end
end
