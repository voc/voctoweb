class Event < ActiveRecord::Base
  include Recent
  include FahrplanParser
  include Download

  belongs_to :conference
  has_many :recordings, dependent: :destroy
  has_one :event_info, dependent: :destroy

  accepts_nested_attributes_for :event_info

  validates_presence_of :conference
  validates_presence_of :guid

  def fill_event_info
    if self.conference.downloaded?
      fahrplan = FahrplanParser.new(self.conference.schedule_xml)
      info = fahrplan.events_by_guid[self.guid]

      self.title = info.delete(:title)
      self.event_info = EventInfo.new(info)
    end
  end

  def set_image_filenames(gif_url, poster_url)
    self.gif_filename = File.basename URI(gif_url).path
    self.poster_filename = File.basename URI(poster_url).path
  end

  def download_images(gif_url, poster_url)
    FileUtils.mkdir_p get_images_path
    self.delay.download_gif(gif_url)
    self.delay.download_poster(poster_url)
  end

  def download_gif(url)
    path = get_images_path, self.gif_filename
    download_to_file(url, path)
  end

  def download_poster(url)
    path = File.join get_images_path, self.poster_filename
    download_to_file(url, path)
  end

  def display_name
    self.guid.nil? ? self.id : self.guid
  end

  private

  def get_images_path
    File.join MediaBackend::Application.config.folders[:images_base_dir], self.conference.images_path
  end

end
