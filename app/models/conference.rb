class Conference < ActiveRecord::Base
  include Recent
  include Download

  has_many :events, dependent: :destroy

  validates_presence_of :acronym
  validates_uniqueness_of :acronym

  state_machine :schedule_state, :initial => :not_present do

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
    self.schedule_xml = download(self.schedule_url)
    if self.schedule_xml.nil?
      self.schedule_state = :new
    else
      self.finish_download
    end
  end
  handle_asynchronously :download!

  def display_name
    self.acronym || self.id
  end

end
