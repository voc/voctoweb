module Feeds

  module Helper

    def merge_config(config)
      keep = [ :title, :channel_summary ]
      @config.channel_title = [ @config.channel_title, config[:title] ].join(' - ')
      @config.channel_summary += config[:channel_summary]

      config.each { |k,v|
        next if keep.include? k
        @config[k] = v
      }
    end

    def get_item_title(event)
      conference = event.conference
      title = ''
      if conference.title.present?
        title = conference.title
      elsif conference.acronym.present?
        title = conference.acronym
      end
      title += ": "
      if event.title
        title += event.title
      else
        title += event.slug
      end
      title
    end

    def get_item_description(event)
      description = []
      description << event.description or event.subtitle

      link = event.link
      description << "about this event: #{link}\n" if link

      # file = 'src/browse/bla.page'
      url = @config['base_url'] + event.slug + '.html'
      description << "event on media: #{url}\n"

      description.join
    end

  end

end
