module Frontend
  module ApplicationHelper
    require 'uri'

    def breadcrumbs_trail
      []
    end

    def twitter_url(title, url)
      "http://twitter.com/home?status="+URI.encode_www_form_component(title+": "+url)
    end

    def facebook_url(title, url)
      "https://www.facebook.com/sharer/sharer.php?t="+URI.encode_www_form_component(title)+"&u="+URI.encode_www_form_component(url)
    end

    def googleplus_url(title, url)
      "https://plus.google.com/share?title="+URI.encode_www_form_component(title)+"&url="+URI.encode_www_form_component(url)
    end

    def appnet_url(title, url)
      "https://alpha.app.net/intent/post?text="+URI.encode_www_form_component(title+": "+url)
    end

    def mail_url(title, url)
      content = URI.encode_www_form_component(title+': '+url)
      subject = URI.encode_www_form_component(title)
      URI::MailTo.build(['', [['Subject', subject], ['Body', content]]]).to_s
    end

    def oembed_url(identifier)
      Settings.oembedURL + identifier[0..-2] + '.html'
    end

    # TODO returns url to omebed page for recording?
    def oembed_page_url(identifier)
      id = identifier+"oembed/"
      return ''
      oembed = @event.recordings.find { |i| i.identifier == id }
      Settings.baseURL + oembed.path
    end

    def page_url(identifier)
      return ''
      Settings.baseURL + identifier.path
    end

    def event_page_or_folder(item)
      return if item.identifier.include? '/tags/'
      trail = breadcrumbs_trail
      return unless trail.count > 2 or item.identifier.include? '/browse/'
      trail = trail[0..-2] if item.identifier.include? '/download/'
      yield trail
    end

    def video_download_sources(recordings)
      skip = %w[vnd.voc/mp4-web vnd.voc/webm-web]
      recordings.reject { |r| skip.include? r.mime_type }
    end

    def video_tag_sources(recordings, order=MimeType::WEB_PREFERRED_VIDEO)
      scores = {}
      recordings.select { |r| order.include? r.mime_type }.each { |r|
        pos = order.index r.mime_type
        fail r.mime_type unless pos
        if scores.has_key? r.display_mime_type
          scores[r.display_mime_type] = pos unless scores[r.display_mime_type] < pos
        else
          scores[r.display_mime_type] = pos
        end
      }
      scores.map { |_, pos|
        mime_type = order[pos]
        recordings.detect { |r| r.mime_type == mime_type }
      }
    end

    def keywords
      if @event and @event.tags
        [ @event.tags, Settings.header['keywords']].join(', ')
      else
        Settings.header['keywords']
      end
    end

    def recording_length(recordings)
      return unless recordings.present?
      recording = recordings.select { |r| r.length.present? }.first
      recording_length_minutes(recording) unless recording.nil?
    end

    def recording_length_minutes(recording)
      if recording.length > 0
        "#{recording.length / 60} min"
      end
    end

    def video_for_flash(recordings)
      url = recordings.select { |recording| recording.display_mime_type == 'video/mp4' }.first.try(:url)
      if url.present?
        h(url)
      elsif recordings.present?
        h(recordings.first.url)
      else
        # :(
        ''
      end
    end

    def aspect_ratio_width(high=true)
      conference = @conference
      case conference.aspect_ratio
      when /16:9/
        high ? '640' : '188'
      when /4:3/
        high ? '400' : '120'
      else
      end
    end

    def aspect_ratio_height(high=true)
      conference = @conference
      case conference.aspect_ratio
      when /16:9/
        high ? '360' : '144'
      when /4:3/
        high ? '300' : '90'
      else
      end
    end

    def date(event)
      date = event.release_date || event.date
      date.strftime("%Y-%m-%d") if date
    end

    def datetime(event)
      date = event.release_date || event.date
      date.strftime("%Y-%m-%d %H:%M") if date
    end

    def parse_url_host(urlish)
      begin
        URI.parse(@event.link).host()
      rescue URI::InvalidURIError
        return ""
      end
    end
  end
end
