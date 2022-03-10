# # frozen_string_literal: true
# generate rssfeed from svn log
module Feeds
  class RdfGenerator
    require 'rss'
    require 'rss/1.0'
    require 'rss/maker'
    require 'rss/content'
    include Feeds::Helper

    def initialize(config: {}, view_context: nil)
      @view_context = view_context
      @config = OpenStruct.new Settings.feeds
      merge_config(config)
    end
    attr_reader :config
    attr_writer :config

    def generate(events)
      rss = RSS::Maker.make("1.0") do |maker|
        create_channel(maker)
        events.each do |event|
          recording = event.preferred_recording
          next if recording.nil?
          fill_item(maker.items.new_item, event, recording)
        end

      end
      rss.to_s
    end

    private

    def create_channel(maker)
      maker.channel.title = @config.channel_title
      maker.channel.about = File.join(@config.base_url, 'updates.rdf')
      maker.channel.link = @config.base_url
      maker.channel.description = @config.channel_description
      maker.image.title = @config.channel_title
      maker.image.url = @config.logo_image
      #maker.items.do_sort = true
    end

    def fill_item(item, event, recording)
      item.link = recording.url
      item.title = get_item_title(event)
      item.description = get_item_description(event)

      item.content_encoded = <<EOF
<div align="center">
      #{item.description}<br/>
    <a href="#{@view_context.event_url(slug: event.slug)}"><img src="#{event.thumb_url}" /></a><br/>
    <b>Video:</b><a href="#{recording.url}">#{recording.filename}</a>
</div>
EOF
      item.pubDate = event.display_date
    end
  end
end
