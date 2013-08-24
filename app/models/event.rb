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

  def set_image_filenames(thumb_url, gif_url, poster_url)
    self.thumb_filename = File.basename URI(thumb_url).path
    self.gif_filename = File.basename URI(gif_url).path
    self.poster_filename = File.basename URI(poster_url).path
  end

  def download_images(thumb_url, gif_url, poster_url)
    FileUtils.mkdir_p get_images_path
    self.delay.download_image(thumb_url, thumb_filename)
    self.delay.download_image(gif_url, gif_filename)
    self.delay.download_image(poster_url, poster_filename)
  end

  def download_image(url, filename)
    path = File.join get_images_path, filename
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
