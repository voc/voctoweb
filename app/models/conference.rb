class Conference < ActiveRecord::Base
  include Recent
  include Storage

  ASPECT_RATIO = [ '4:3', '16:9' ]

  has_many :events, dependent: :destroy

  validates_presence_of :acronym
  validates_presence_of :webgen_location
  validates_uniqueness_of :acronym
  validates_uniqueness_of :webgen_location

  has_attached_directory :images,
    via: :images_path,
    prefix: MediaBackend::Application.config.folders[:images_base_dir],
    url: MediaBackend::Application.config.staticURL,
    url_path: MediaBackend::Application.config.folders[:images_webroot]

  has_attached_directory :recordings,
    via: :recordings_path,
    prefix: MediaBackend::Application.config.folders[:recordings_base_dir],
    url: MediaBackend::Application.config.cdnURL,
    url_path: MediaBackend::Application.config.folders[:recordings_webroot]

  state_machine :schedule_state, :initial => :not_present do

    after_transition any => :new do |conference, transition|
      conference.start_download
    end

    after_transition any => :downloading do |conference, transition|
      conference.download!
    end

    state :not_present
    state :new
    state :downloading
    state :downloaded

    event :url_changed do
      transition all => :new
    end

    event :start_download do
      transition [:new] => :downloading
    end

    event :finish_download do
      transition [:downloading] => :downloaded
    end

  end

  def download!
    return unless self.schedule_url
    self.schedule_xml = download(self.schedule_url)
    if self.schedule_xml.nil?
      self.schedule_state = :new
    else
      self.finish_download
    end
    self.save
  end

  def self.run_compile_job
    Rails.logger.info "Compiling static website"
    `sudo -u media-frontend /srv/www/media-frontend/media-frontend/bin/nanoc-wrapper` unless Rails.env.test?
  end

  def self.run_fast_compile_job
    Rails.logger.info "Fast Compiling static website"
    `sudo -u media-frontend /srv/www/media-frontend/media-frontend/bin/nanoc-fast-wrapper` unless Rails.env.test?
  end

  def get_event_url(id)
    if self.schedule_url.present?
      return self.schedule_url.sub('schedule.xml', "events/#{id}.html")
    end
  end

  # frontend generates logos like this:
  def logo_url
    if self.logo
      File.join MediaBackend::Application.config.frontendURL, 'images/logos', self.images_path, File.basename(self.logo, File.extname(self.logo))+'.png'
    else
      File.join MediaBackend::Application.config.frontendURL, 'images/logos/unknown.png'
    end
  end

  def display_name
    self.acronym || self.id
  end

  def validate_for_api
    self.errors.add :images_path, "images path #{self.get_images_path} not writable" unless File.writable? self.get_images_path
    self.errors.add :recordings_path, "recordings path #{self.get_recordings_path} not writable" unless File.writable? self.get_recordings_path
    not self.errors.any?
  end
end
