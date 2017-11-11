class ConferenceStreamingDownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform
    url = ENV['STREAMING_URL']
    return unless url

    logger.info "downloading streaming configs from #{url}"
    streaming_response = download(url)
    streaming = JSON.parse(streaming_response)

    Conference.transaction do
      Conference.update_all(streaming: {})
      streaming.each do |conference_data|
        conference = Conference.find_by(acronym: conference_data['slug'])
        next unless conference
        logger.info "updating streaming config for #{conference.acronym}"
        conference.update(streaming: conference_data)
      end
    end
  end
end
