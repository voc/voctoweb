class Event < ActiveRecord::Base
  include Recent
  include FahrplanParser

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

  def display_name
    self.guid.nil? ? self.id : self.guid
  end

end
