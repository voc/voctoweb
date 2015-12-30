class AddOriginalLanguageToEvent < ActiveRecord::Migration
  def change
    add_column :events, :original_language, :string

    Event.find_each do |event|
      languages = Event.last.recordings.pluck(:language).uniq
      next if languages.empty?
      event.original_language = languages.max.split(/-/).first
      event.save
    end
  end
end
