class Conference < ActiveRecord::Base
  include Recent

  has_many :events,  dependent: :destroy
end
