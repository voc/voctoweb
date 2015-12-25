# frozen_string_literal: true
module Feeds
  module Helper
    def merge_config(config)
      keep = [:title, :channel_summary]
      @config.channel_title = [@config.channel_title, config[:title]].join(' - ')
      @config.channel_summary += config[:channel_summary]

      config.each { |k, v|
        next if keep.include? k
        @config[k] = v
      }
    end

    def get_item_title(event)
      "#{event.title} (#{event.conference.acronym})"
    end

    def get_item_description(event)
      description = []
      description << event.description

      link = event.link
      description << "about this event: #{link}\n" if link

      description.join("\n")
    end
  end
end
