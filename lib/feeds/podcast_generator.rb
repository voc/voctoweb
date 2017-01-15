# # frozen_string_literal: true
# generate iTunes store feed
module Feeds
  class PodcastGenerator
    require 'rss/2.0'
    require 'rss/itunes'
    require 'rss/maker'
    require 'rss/content'
    include Feeds::Helper

    def initialize(view_context, config = {})
      @view_context = view_context
      @config = OpenStruct.new Settings.feeds
      merge_config(config)
    end
    attr_reader :config
    attr_writer :config

    def generate(events)
      rss = RSS::Maker.make('2.0') do |maker|
        create_channel(maker)

        events.each do |event|
          recording = yield event
          next if recording.nil?

          fill_item(maker.items.new_item, event, recording)
        end
      end
      rss.to_s
    end

    private

    def create_channel(maker)
      maker.channel.title = @config.channel_title
      maker.channel.generator =  'media.ccc.de / RSS ' + RSS::VERSION
      maker.channel.link =  @config.base_url
      maker.channel.description = @config.channel_description
      maker.channel.copyright = 'mostly cc-by-nc'
      maker.channel.lastBuildDate = Time.now.utc.to_s

      # see http://www.apple.com/itunes/podcasts/specs.html#category
      # category = maker.channel.itunes_categories.new_category
      # category.text = "Technology"
      # category.new_category.text = "Technology"
      maker.channel.itunes_categories.new_category.text = 'Technology'

      # TODO png/jpg?
      maker.image.url = @config.logo_image
      maker.image.title = @config.channel_title
      maker.channel.itunes_author = @config.channel_owner
      maker.channel.itunes_owner.itunes_name = @config.channel_owner
      maker.channel.itunes_owner.itunes_email = 'media@koeln.ccc.de'
      maker.channel.itunes_keywords = @config.channel_keywords
      maker.channel.itunes_subtitle = @config.channel_subtitle
      maker.channel.itunes_summary = @config.channel_summary

      maker.channel.itunes_image = @config.logo_image
      maker.channel.itunes_explicit = 'No'
    end

    def fill_item(item, event, recording)
      item.title = get_item_title(event)
      item.link = @view_context.event_url(slug: event.slug)
      item.itunes_keywords = event.try(:tags).join(',')
      item.guid.content = recording.url + '?' + recording.created_at.to_i.to_s
      item.guid.isPermaLink = true
      item.dc_identifier = event.guid

      # FIXME decode, redcloth, whatever
      description = get_item_description(event)
      item.description = description
      item.itunes_duration = Time.at(recording.length).utc.strftime '%H:%M:%S'
      item.itunes_summary = description
      item.itunes_explicit = 'No'
      item.pubDate = event.created_at.to_s

      item.itunes_subtitle = event.subtitle if event.subtitle.present?
      item.itunes_author = event.persons.join(', ') if event.persons.present?
      item.pubDate = event.date.to_s if event.date.present?

      item.enclosure.url = recording.url
      item.enclosure.length = size_to_bytes(recording.size || 0)
      item.enclosure.type = recording.mime_type
    end

    def size_to_bytes(size)
      size * 1024 * 1024
    end
  end
end
