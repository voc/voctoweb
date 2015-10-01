# generate torrent broadcatching feeds for folders
module Feeds
  class BroadcatchingGenerator
    def self.generate(events: [], query: nil, config: {})
      OpenStruct.new(events: events, query: query, config: config)
    end

    def self.config
      config = OpenStruct.new Settings.feeds
      merge_config(config)
    end
    private_class_method :config
  end
end
