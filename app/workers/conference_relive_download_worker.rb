class ConferenceReliveDownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform
    url = ENV['RELIVE_URL']
    return unless url

    logger.info "downloading relive toc from #{url}"
    response = download(url)
    relive_toc = JSON.parse(response)

    return unless relive_toc&.is_a?(Array)

    relive_toc.each do |r|
      next unless r.key?('media_conference_id')
      conference = Conference.find_by(acronym: r['project'])
      next unless conference

      next unless recently_updated?(r['updated_at'])

      relive = download_relive_event(r['index_url'])
      next unless relive&.is_a?(Array)

      logger.info "updating relive data for #{conference.acronym}"
      relive.reject! { |r| not r['playlist'] }
      relive.each { |r| r['playlist'] = protocol_relative_url(r['playlist']) }

      conference.metadata['relive'] = relive
      conference.save
    end
  end

  private

  def download_relive_event(url)
    url = protocol_relative_url(url)
    logger.info "downloading relive data for '#{url}'"
    response = download(url)
    JSON.parse(response)
  rescue OpenURI::HTTPError => e
    logger.error("failed to download '#{url}': #{e}")
  end

  def recently_updated?(date)
    Time.at(date).to_date > Time.now.ago(1.year)
  end

  def protocol_relative_url(url)
    return url if url.start_with?('http') || url.start_with?('file')
    'https:' + url
  end
end
