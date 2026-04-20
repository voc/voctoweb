# frozen_string_literal: true
class ActivityPub::ImageSerializer < ActivityPub::Serializer
  attributes :type, :url, :media_type, :width, :height

  def type
    'Image'
  end

  def media_type
    object.media_type || 'image/jpeg'
  end

  def url
    object.url
  end

  def width
    object.width
  end

  def height
    object.height
  end
end
end


=begin
class ActivityPub::ImageSerializer < ActivityPub::Serializer

  attributes :type, :media_type, :url

  def type
    'Image'
  end

  def url
    full_asset_url(object.url(:original))
  end

  def media_type
    object.content_type
  end
end
=end