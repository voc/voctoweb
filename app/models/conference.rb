class Conference < ActiveRecord::Base
  include Recent

  has_many :events, dependent: :destroy

  validates_presence_of :acronym

  state_machine :initial => :not_present do
    state :not_present
    state :new
    state :downloading
    state :downloaded

    event :entered do
      transition all => :new
    end

    event :start_download do
      transition [:new] => :downloading
    end

    event :finish_download do
      transition [:downloading] => :downloaded
    end

  end

  def display_name
    self.acronym || self.id
  end

end
