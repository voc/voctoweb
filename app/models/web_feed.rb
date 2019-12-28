class WebFeed < ApplicationRecord
  FEEDS_TIMESPAN = 1.years

  validates :key, :last_build, :content, presence: true

  scope :newer, ->(date) { where('last_build > ?', date) }

  def self.last_year
    self.round_to_quarter_hour(Time.now.ago(FEEDS_TIMESPAN))
  end

  def self.update_with_lock(time, selector={})
    feed = WebFeed.find_or_create_by(selector)
    feed.with_lock do
      return if feed.newer?(time)
      feed.last_build = time || Time.now
      yield feed
      feed.save
    end
  end

  def self.folder_key(conference, quality, mime_type)
    "#{conference.acronym}#{quality}#{mime_type}"
  end

  def newer?(date)
    return unless last_build && date
    last_build >= date
  end

  private

  def self.round_to_quarter_hour(time)
    seconds = 15 * 60
    Time.at((time.to_f / seconds).floor * seconds)
  end
end
