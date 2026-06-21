namespace :voctoweb do
  namespace :recordings do
    desc 'Update recording sizes from a filesizes.json manifest (CDN url => size in bytes)'
    task update_sizes: :environment do
      path = ENV['FILESIZES_PATH'] || Rails.root.join('filesizes.json')

      # Match URLs scheme-agnostically: filesizes.json was crawled against
      # the production https CDN, but Settings.cdn_url may be configured
      # with http (e.g. in development), so a literal string match would
      # silently miss every recording.
      strip_scheme = ->(url) { url.sub(%r{^https?://}, '') }
      filesizes = JSON.parse(File.read(path)).transform_keys(&strip_scheme)

      # fsck2025's files are listed in the manifest under .../fsck/2025/...
      # rather than .../fsck/fsck2025/... like recording.url computes (every
      # other fsck year matches the manifest literally) - apparently a
      # one-off naming quirk from how that year was published to the CDN.
      url_overrides = { 'fsck2025' => ->(url) { url.sub('/fsck/fsck2025/', '/fsck/2025/') } }

      recordings = Recording.all.to_a
      total = recordings.count
      puts "Updating #{total} recordings from #{path}..."

      updated = 0
      missing = 0

      recordings.each_with_index do |recording, index|
        url = strip_scheme.call(recording.url)
        size = filesizes[url]

        if size.nil? && (override = url_overrides[recording.conference.acronym])
          size = filesizes[override.call(url)]
        end

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
