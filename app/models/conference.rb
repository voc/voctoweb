class Conference < ApplicationRecord
  include Recent
  include Storage
  include AASM

  ASPECT_RATIO = ['4:3', '16:9']

  has_many :events, dependent: :destroy

  validates :acronym, :slug, presence: true
  validates :acronym, :slug, uniqueness: true
  validates :slug, format: { with: %r{\A\w+(?:/\w+)*\z} }
  validate :schedule_url_valid
  validate :slug_reachable

  has_attached_directory :images,
    via: :images_path,
    url: Settings.static_url,
    url_path: Settings.folders['images_webroot']

  has_attached_directory :recordings,
    via: :recordings_path,
    url: Settings.cdn_url,
    url_path: Settings.folders['recordings_webroot']

  before_save { trim_paths }

  aasm column: :schedule_state do
    state :not_present, initial: true
    state :new
    state :downloading
    state :downloaded

    event :url_changed, after: :start_download! do
      transitions to: :new
    end

    event :start_download, after: :download! do
      transitions from: :new, to: :downloading
    end

    event :finish_download do
      transitions from: :downloading, to: :downloaded
    end
  end

  def download!
    return unless schedule_url
    ScheduleDownloadWorker.perform_async(id)
  end

  def get_event_url(id)
    if schedule_url.present?
      return schedule_url.sub('schedule.xml', "events/#{id}.html").freeze
    end
  end

  # frontend generates logos like this:
  def logo_url
    if logo_exists?
      File.join Settings.static_url, images_path, logo
    else
      File.join Settings.static_url, 'unknown.png'
    end.freeze
  end

  def display_name
    acronym || id
  end

  private

  def logo_exists?
    return if logo.blank?
    true
  end

  def slug_reachable
    return unless Conference.pluck(:slug).any? { |s| s.starts_with?(slug + '/') }
    errors.add :slug, "can't add conference below another conference"
  end

  def schedule_url_valid
    return unless schedule_url
    URI.parse(schedule_url)
  rescue URI::Exception
    errors.add :schedule_url, 'not a valid url'
  end

  def trim_paths
    logo.strip! unless logo.blank?
    schedule_url.strip! unless schedule_url.blank?
    images_path.strip! unless images_path.blank?
    recordings_path.strip! unless recordings_path.blank?
  end
end
