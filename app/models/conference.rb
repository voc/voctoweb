class Conference < ActiveRecord::Base
  include Recent
  include Storage
  include AASM

  ASPECT_RATIO = ['4:3', '16:9']

  has_many :events, dependent: :destroy

  validates_presence_of :acronym
  validates_presence_of :slug
  validates_uniqueness_of :acronym
  validates_uniqueness_of :slug
  validates :slug, format: { with: %r{\A\w+(?:/\w+)*\z} }
  validate :slug_reachable

  has_attached_directory :images,
    via: :images_path,
    prefix: Settings.folders['images_base_dir'],
    url: Settings.static_url,
    url_path: Settings.folders['images_webroot']

  has_attached_directory :recordings,
    via: :recordings_path,
    prefix: Settings.folders['recordings_base_dir'],
    url: Settings.cdn_url,
    url_path: Settings.folders['recordings_webroot']

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
      return schedule_url.sub('schedule.xml', "events/#{id}.html")
    end
  end

  # frontend generates logos like this:
  def logo_url
    if logo
      File.join Settings.static_url, images_path, File.basename(logo, File.extname(logo)) + '.png'
    else
      File.join Settings.static_url, 'unknown.png'
    end
  end

  def display_name
    acronym || id
  end

  def validate_for_api
    errors.add :images_path, "images path #{get_images_path} not writable" unless File.writable? get_images_path
    errors.add :recordings_path, "recordings path #{get_recordings_path} not writable" unless File.writable? get_recordings_path
    not errors.any?
  end

  private

  def slug_reachable
    return unless Conference.pluck(:slug).any? { |s| s.starts_with?(slug + '/') }
    errors.add :slug, "can't add conference below another conference"
  end
end
