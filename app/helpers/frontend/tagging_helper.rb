module Frontend
  # Set the tags attribute on items to use this helper
  module TaggingHelper

    # link to tag page
    def link_for_global(tag, css: '')
      %[<a href="/tags/#{h tag}" rel="tag" class="#{css} label label-default">#{h tag}</a>]
    end

    def link_for(conference, tag, css: '')
      %[<a href="/c/#{h conference.acronym}/#{h tag}" rel="tag" class="#{css} label label-default">#{h tag}</a>]
    end

    #
    def tag_cloud
      return [] if @tags.empty?
      tags_hash.map { |tag, count|
        link_for tag, css: css_class_by_size(count)
      }
    end

    private

    def css_class_by_size(n)
      if n < 5
        "xtiny"
      elsif n < 10
        "tiny"
      elsif n < 50
        "normal"
      elsif n < 100
        "large"
      else
        "xlarge"
      end
    end

    def tags_hash
      tags = {}
      @tags.each do |tag, events|
        next unless tag
        tags[tag] = events.count
      end
      tags
    end
  end
end
