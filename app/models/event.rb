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
  validates_uniqueness_of :guid

  before_destroy :delete_page_file

  scope :recordings_by_mime_type, lambda { |type| joins(:recordings).where(recordings: {mime_type: type}) }

  def get_recording_by_mime_type(type)
    self.recordings.where(mime_type: type)
  end

  def recordings_by_mime_type
    Hash[self.recordings.map { |r| [r.mime_type, r] }]
  end

  def fill_event_info
    if self.conference.downloaded?
      fahrplan = FahrplanParser.new(self.conference.schedule_xml)
      info = fahrplan.event_info_by_guid[self.guid]

      self.title = info.delete(:title)
      self.event_info = EventInfo.new(info)
    end
  end

  def set_image_filenames(thumb_url, gif_url, poster_url)
    self.thumb_filename = get_image_filename thumb_url if thumb_url
    self.gif_filename = get_image_filename gif_url if gif_url
    self.poster_filename = get_image_filename poster_url if poster_url
  end

  def download_images(thumb_url, gif_url, poster_url)
    FileUtils.mkdir_p self.conference.get_images_path
    self.delay.download_image(thumb_url, thumb_filename)
    self.delay.download_image(gif_url, gif_filename)
    self.delay.download_image(poster_url, poster_filename)
  end

  def download_image(url, filename)
    return if url.nil? or filename.nil?
    path = File.join self.conference.get_images_path, filename
    download_to_file(url, path)
  end

  def get_videopage_filename
    if self.event_info and not self.event_info.slug.nil?
      filename = self.event_info.slug + '.page'
    else
      filename = self.guid + '.page'
    end
    filename.gsub!(/ /, '_')
    page_file = File.join(self.conference.get_webgen_location, filename)
    page_file
  end

  def display_name
    self.guid.nil? ? self.id : self.guid
  end

  private

  def delete_page_file
    VideopageBuilder.remove_videopage(self.event.conference, self.event)
  end

  def get_image_filename(url)
    if url
      File.basename URI(url).path
    else
      ""
    end
  end

end
