class ActivityPub::Serializer < ActiveModel::Serializer
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  # These class attributes store ActivityPub-specific context information
  class_attribute :_context
  class_attribute :_context_extensions

  class << self
    # Define context namespace for ActivityPub
    def context(context_name)
      self._context ||= []
      self._context << context_name
    end

    # Define context extensions for ActivityPub
    def context_extensions(*extensions)
      self._context_extensions ||= []
      self._context_extensions += extensions
    end

  end

  # Override as_json to add ActivityPub context
  def as_json(options = {})
    hash = super(options)
    add_context(hash)
  end

  protected

  def add_context(hash)
    context = {}

    if self.class._context.present?
      context_array = ['https://www.w3.org/ns/activitystreams']
      context_array << 'https://w3id.org/security/v1' if self.class._context.include?(:security)

      if self.class._context_extensions.present?
        extensions = {}
        # Define ActivityPub extensions
        extensions['pt'] = 'https://joinpeertube.org/ns#' if self.class._context_extensions.include?(:pt)
        extensions['sc'] = 'http://schema.org/#' if self.class._context_extensions.include?(:sc)
        extensions['language'] = {'@id': 'sc:inLanguage', '@container': '@language'} if self.class._context_extensions.include?(:language)
        extensions['views'] = 'pt:views' if self.class._context_extensions.include?(:views)
        extensions['collection'] = 'as:Collection' if self.class._context_extensions.include?(:collection)
        extensions['items'] = 'as:items' if self.class._context_extensions.include?(:items)
        extensions['total_items'] = 'as:totalItems' if self.class._context_extensions.include?(:total_items)

        context_array << extensions unless extensions.empty?
      end

      context = context_array.size == 1 ? context_array.first : context_array
    end

    hash['@context'] = context unless context.empty?
    hash
  end
end
