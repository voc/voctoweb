class ScheduleDownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform(conference_id)
    conference   = Conference.find(conference_id)
    schedule_url = conference.schedule_url
    logger.info "downloading schedule for #{conference.acronym}"
    schedule = download(schedule_url)
    conference.schedule_xml = schedule
    if schedule.nil?
      conference.schedule_state = :new
      conference.save
    else
      conference.schedule_url = schedule_url
      if conference.speakers_json_url.present?
        conference.speakers_json = download(conference.speakers_json_url)
      end
      conference.finish_download!
      PersonImportWorker.perform_async(conference_id) if json_schedule?(schedule)
    end
  end

  private

  def json_schedule?(content)
    content.to_s.lstrip[0] == '{'
  end
end
