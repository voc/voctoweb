class EventInfo < ActiveRecord::Base
  belongs_to :event
  serialize :persons, Array
  serialize :tags, Array

  # active admin and serialized fields workaround:
  #
  attr_accessor   :persons_raw, :tags_raw

  def persons_raw
    self.persons.join("\n") unless self.persons.nil?
  end

  def persons_raw=(values)
    self.persons = []
    self.persons = values.split("\n")
  end

  def tags_raw
    self.tags.join("\n") unless self.tags.nil?
  end

  def tags_raw=(values)
    self.tags = []
    self.tags= values.split("\n")
  end
end
