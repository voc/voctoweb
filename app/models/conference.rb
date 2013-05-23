class Conference < ActiveRecord::Base
  include Recent

  has_many :events,  dependent: :destroy

  def to_s
    self.acronym
  end
end
