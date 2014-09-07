class ImportTemplate < ActiveRecord::Base
  include Storage

  validates_presence_of :acronym
  validates_presence_of :webgen_location, :recordings_path, :images_path, :aspect_ratio, :release_date, :mime_type
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }

  validates_uniqueness_of :acronym
  validates_uniqueness_of :webgen_location

  has_attached_directory :images, 
    via: :images_path,
    prefix: MediaBackend::Application.config.folders[:images_base_dir],
    url: MediaBackend::Application.config.staticURL,
    url_path: MediaBackend::Application.config.folders[:images_webroot]

  has_attached_directory :recordings, 
    via: :recordings_path,
    prefix: MediaBackend::Application.config.folders[:recordings_base_dir],
    url: MediaBackend::Application.config.cdnURL,
    url_path: MediaBackend::Application.config.folders[:recordings_webroot]

  has_attached_file :logo, via: :logo, belongs_into: :images

  def recordings
    images = Dir[File.join(get_images_path, '*')]
    Dir[File.join(get_recordings_path, folder, '*')].map { |path|

      slug = File.basename path, '.*'
      search_poster_by_slug = /#{slug}.*_preview\.jpg/
      search_thumb_by_slug = /#{slug}.*?\.jpg/

      OpenStruct.new filename: File.basename(path),
        poster: match_and_delete(images, search_poster_by_slug),
        thumb: match_and_delete(images, search_thumb_by_slug)
    }
  end

  private

  def match_and_delete(images, regexp)
    paths = images.select { |i| i[regexp] }
    if paths.present?
      images.delete paths.first
      return OpenStruct.new found: true, filename: File.basename(paths.first)
    end
    return OpenStruct.new found: false
  end

end
