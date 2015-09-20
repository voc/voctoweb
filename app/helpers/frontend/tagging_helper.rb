module Frontend
  # Set the tags attribute on items to use this helper
  module TaggingHelper

    # link to tag page
    def link_for(tag, prefix: '/browse/tags/', css: '')
      %[<a href="#{h prefix}#{h tag}.html" rel="tag" class="#{css} label label-default">#{h tag}</a>]
    end

    #
    def tag_cloud(prefix: '/browse/tags/')
      return [] if @items.nil?
      tags_hash.map { |tag, count|
        link_for tag, prefix: prefix, css: css_class_by_size(count)
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
      tags = Hash.new { |h,k| h[k] = [] }
      @items.each do |i|
        next unless i[:tag]
        tags[i[:title]] = i[:events].count
      end
      tags
    end
  end
end
