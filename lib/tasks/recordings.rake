namespace :voctoweb do
  namespace :recordings do
    desc 'Update recordings sizes by fetching content-length using HEAD requests'
    task update_sizes: :environment do
      require 'net/http'
      require 'uri'

      def fetch_content_length(url, limit = 10)
        return nil if limit == 0

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = 5
        http.read_timeout = 5

        response = http.request_head(uri.request_uri)

        case response
        when Net::HTTPSuccess
          response['content-length']&.to_i
        when Net::HTTPRedirection
          location = response['location']
          if location
            new_url = URI.join(url, location).to_s
            fetch_content_length(new_url, limit - 1)
          else
            nil
          end
        else
          nil
        end
      rescue => e
        puts "Error fetching #{url}: #{e.message}"
        nil
      end

      recordings = Recording.all
      total = recordings.count
      puts "Starting update of #{total} recordings..."
      
      updated = 0
      failed = 0

      recordings.each_with_index do |recording, index|
        url = recording.url
        print "[#{index + 1}/#{total}] Querying size for #{recording.filename}... "
        
        content_length = fetch_content_length(url)

        if content_length && content_length > 0
          recording.update_column(:size, content_length)
          puts "Success: #{content_length} bytes"
          updated += 1
        else
          puts "Failed"
          failed += 1
        end
      end

      puts "Update completed. #{updated} updated, #{failed} failed."
    end
  end
end
