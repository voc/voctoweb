class Recording < ActiveRecord::Base

  belongs_to :event

  validates_presence_of :event
  validates_presence_of :path

  state_machine :state, :initial => :new do

    state :new
    state :downloading
    state :downloaded
    state :releasing
    state :released

    event :start_download do
      transition [:new] => :downloading
    end

    event :finish_download do
      transition [:downloading] => :downloaded
    end

    event :start_release do
      transition [:downloaded] => :releasing
    end

    event :finish_release do
      transition [:releasing] => :released
    end

  end

end
