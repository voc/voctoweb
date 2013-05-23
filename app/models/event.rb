class Event < ActiveRecord::Base

  belongs_to :conference
  has_many :recordings, dependent: :destroy
  has_one :event_info, dependent: :destroy

  accepts_nested_attributes_for :event_info

  validates_presence_of :conference
  validates_presence_of :guid

  def display_name
    self.guid.nil? ? self.id : self.guid
  end

end
