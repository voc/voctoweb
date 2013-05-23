class Conference < ActiveRecord::Base
  include Recent

  has_many :events, dependent: :destroy

  validates_presence_of :acronym

  def display_name
    self.acronym || self.id
  end

end
