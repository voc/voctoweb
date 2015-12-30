class ScheduleDownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform(conference_id)
    conference = Conference.find(conference_id)
    logger.info "downloading schedule for #{conference.acronym}"
    conference.schedule_xml = download(conference.schedule_url)
    if conference.schedule_xml.nil?
      conference.schedule_state = :new
      conference.save
    else
      conference.finish_download!
    end
  end
end
