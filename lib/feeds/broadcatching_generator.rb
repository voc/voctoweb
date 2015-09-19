# generate torrent broadcatching feeds for folders
module Feeds
  module BroadcatchingGenerator

    def self.generate(events: [], query: nil, config: {})
      rss = BroadcatchingGenerator::TorrentRSS.new config
      rss.generate events, query
    end

    class TorrentRSS
      include Feeds::Helper

      def initialize(config)
        @config = OpenStruct.new Settings.feeds
        merge_config(config)
      end
      attr_reader :config
      attr_writer :config

      def generate(events, query)
        template = File.read('lib/feeds/broadcatching.xml.haml')
        haml_engine = Haml::Engine.new(template)
        output = haml_engine.render(self, events: events, query: query, config: @config)
        output
      end
    end

  end
end
