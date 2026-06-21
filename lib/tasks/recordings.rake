namespace :voctoweb do
  namespace :recordings do
    desc 'Update recording sizes from a filesizes.json manifest (CDN url => size in bytes)'
    task update_sizes: :environment do
      path = ENV['FILESIZES_PATH'] || Rails.root.join('filesizes.json')
      filesizes = JSON.parse(File.read(path))

      recordings = Recording.all.to_a
      total = recordings.count
      puts "Updating #{total} recordings from #{path}..."

      updated = 0
      missing = 0

      recordings.each_with_index do |recording, index|
        size = filesizes[recording.url]

        if size && size > 0
          recording.update_column(:size, size)
          updated += 1
          puts "[#{index + 1}/#{total}] #{recording.filename}: #{size} bytes"
        else
          missing += 1
          puts "[#{index + 1}/#{total}] #{recording.filename}: not found in #{path}"
        end
      end

      puts "Update completed. #{updated} updated, #{missing} missing."
    end
  end
end
