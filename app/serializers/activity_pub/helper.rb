# Helper serializers
class ActivityPub::LanguageSerializer < ActivityPub::Serializer
  attributes :identifier, :name
end

class ActivityPub::PersonSerializer < ActivityPub::Serializer
  attributes :type, :name

  def type
    'Person'
  end
end

class ActivityPub::HashtagSerializer < ActivityPub::Serializer
  attributes :type, :name

  def type
    'Hashtag'
  end
end

class ActivityPub::LinkSerializer < ActivityPub::Serializer
  attributes :type, :media_type, :href, :height, :size, :fps, :rel

  def type
    'Link'
  end

  # These methods handle both model objects and hash wrappers
  def media_type
    object.respond_to?(:media_type) ? object.media_type : nil
  end

  def href
    object.respond_to?(:href) ? object.href : nil
  end

  def height
    object.respond_to?(:height) ? object.height : nil
  end

  def size
    object.respond_to?(:size) ? object.size : nil
  end

  def fps
    object.respond_to?(:fps) ? object.fps : nil
  end

  def rel
    object.respond_to?(:rel) ? object.rel : nil
  end
end