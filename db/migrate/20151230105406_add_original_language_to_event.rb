class AddOriginalLanguageToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :original_language, :string

    Event.find_each do |event|
      languages = event.recordings.pluck(:language).uniq
      next if languages.empty?
      event.original_language = languages.max_by(&:length).split(/-/).first
      event.save
    end
  end
end
