namespace :voctoweb do
  namespace :recordings do
    desc 'Update recordings sizes by fetching content-length using HEAD requests'
    task update_sizes: :environment do
      require 'parallel'
      require 'faraday'
      require 'faraday/follow_redirects'
      require 'httpx/adapters/faraday'

      def fetch_content_length(url)
        retries = 3
        begin
          conn = (Thread.current[:faraday_connection] ||= Faraday.new do |f|
            f.response :follow_redirects, limit: 10
            f.options.timeout = 5
            f.options.open_timeout = 5
            f.adapter :httpx
          end)

          response = conn.head(url)

          if response.success?
            response.headers['content-length']&.to_i
          elsif response.status == 404
            nil
          else
            raise "HTTP status #{response.status}"
          end
        rescue => e
          if retries > 0
            retries -= 1
            puts "Retrying fetch for #{url} (remaining retries: #{retries}) due to error: #{e.message}"
            sleep(0.5)
            retry
          else
            puts "Error fetching #{url}: #{e.message}"
            nil
          end
        end
      end

      recordings = Recording.all.to_a
      total = recordings.count
      puts "Starting update of #{total} recordings..."

      results = Parallel.map_with_index(recordings, in_threads: 10) do |recording, index|
        ActiveRecord::Base.connection_pool.with_connection do
          url = recording.url
          content_length = fetch_content_length(url)

          if content_length && content_length > 0
            recording.update_column(:size, content_length)
            puts "[#{index + 1}/#{total}] Querying size for #{recording.filename}... Success: #{content_length} bytes"
            true
          else
            puts "[#{index + 1}/#{total}] Querying size for #{recording.filename}... Failed"
            false
          end
        end
      end

      updated = results.count(true)
      failed = results.count(false)

      puts "Update completed. #{updated} updated, #{failed} failed."
    end
  end
end
