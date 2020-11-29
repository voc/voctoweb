class MoveEventInfoDataToEvent < ActiveRecord::Migration[4.2]

=begin
  def up
    EventInfo.all.each do |ei|
      next if ei.event.nil?
      ei.event.date = ei.date
      ei.event.description = ei.description
      ei.event.link = ei.link
      ei.event.persons = ei.persons
      ei.event.slug = ei.slug
      ei.event.subtitle = ei.subtitle
      ei.event.tags = ei.tags
      ei.event.save!
    end
  end

  def down
    Events.all.each do |e|
      ei = EventInfo.new
      ei.date = e.date
      ei.description = e.description
      ei.link = e.link
      ei.persons = e.persons
      ei.slug = e.slug
      ei.subtitle = e.subtitle
      ei.tags = e.tags
      ei.event = e
      ei.save!
    end
  end
=end
end
