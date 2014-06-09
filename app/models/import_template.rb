class ImportTemplate < ActiveRecord::Base
  include Storage

  validates_presence_of :acronym
  validates_presence_of :webgen_location, :recordings_path, :images_path, :aspect_ratio, :title, :release_date, :mime_type, :folder

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
    Dir[File.join(get_recordings_path, '*')].map { |path|

      slug = File.basename path, '.*'
      search_gif_by_slug = /#{slug}.*\.gif/
      search_poster_by_slug = /#{slug}.*_preview\.jpg/
      search_thumb_by_slug = /#{slug}.*?\.jpg/

      OpenStruct.new filename: File.basename(path),
        gif: match_and_delete(images, search_gif_by_slug),
        poster: match_and_delete(images, search_poster_by_slug),
        thumb: match_and_delete(images, search_thumb_by_slug)
    }
  end

  private

  def match_and_delete(images, regexp)
    paths = images.select { |i| i[regexp] }
    if paths.present?
      images.delete paths.first
      return true
    end
    return false
  end

end
