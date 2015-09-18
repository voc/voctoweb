module EventFrontend
  extend ActiveSupport::Concern

  included do
    scope :promoted, ->(n) { where(promoted: true).order('updated_at desc').limit(n) }
  end

  def url
    "/browse/#{self.conference.webgen_location}/#{self.slug}.html"
  end

  def thumb_url
    File.join Settings.staticURL, 'media', self.conference.images_path, self.thumb_filename
  end
end
