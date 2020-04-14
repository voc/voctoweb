module Frontend
  module ApplicationHelper
    require 'uri'

    def oembed_api_event_url(event)
      (public_oembed_url(url: event_url(slug: event.slug))).freeze
    end

    def twitter_url(title, url)
      'https://twitter.com/home?status='.freeze + URI.encode_www_form_component(title + ': ' + url)
    end

    def facebook_url(title, url)
      'https://www.facebook.com/sharer/sharer.php?t='.freeze + URI.encode_www_form_component(title) + '&u=' + URI.encode_www_form_component(url)
    end

    def diaspora_url(title, url)
      'https://share.diasporafoundation.org/?title='.freeze + URI.encode_www_form_component(title).gsub(/\+/, '%20') + '&url=' + URI.encode_www_form_component(url)
    end

    def mail_url(title, url)
      content = ERB::Util.url_encode(title + ': ' + url)
      subject = ERB::Util.url_encode(title)
      URI::MailTo.build(['', [['subject', subject], ['body', content]]]).to_s.freeze
    end

    def breadcrumbs_trail
      path = if @conference
               @conference.slug
             elsif @folders
               @folders.last.parent_path
             else
               ''.freeze
             end
      parts = path.split('/')
      return if parts.blank?
      if @playlist
        parts += ['playlist']
      elsif @event
        parts += ['event']
      elsif @tag
        parts += [@tag]
      end
      current = parts.pop
      yield parts.map!(&:freeze), current.freeze
    end

    # TODO which video to prefer?
    def opengraph_video(recordings)
      recordings.first.try(:url)
    end

    def keywords
      if @event&.tags
        [@event.tags, I18n.t('custom.header.keywords')].join(', ')
      else
        I18n.t('custom.header.keywords')
      end
    end

    def duration_in_minutes(duration)
      "#{duration / 60} min" if duration.positive?
    end

    def video_for_flash(recordings)
      url = recordings.find { |recording| recording.mime_type == 'video/mp4' }.try(:url)
      if url.present?
        h(url)
      elsif recordings.present?
        h(recordings.first.url)
      else
        # :(
        ''
      end
    end

    def aspect_ratio_width(high = true)
      case @conference.aspect_ratio
      when /16:9/
        high ? '640' : '188'
      when /4:3/
        high ? '400' : '120'
      end
    end

    def aspect_ratio_height(high = true)
      case @conference.aspect_ratio
      when /16:9/
        high ? '360' : '144'
      when /4:3/
        high ? '300' : '90'
      end
    end

    def aspect_ratio_height_vw
      case @conference.aspect_ratio
      when /16:9/
        '56.25vw'
      when /4:3/
        '75vw'
      end
    end

    def persons_icon(persons)
      if persons.length <= 1
        'icon-user-light'.freeze
      else
        'icon-users-light'.freeze
      end
    end

    def display_release_date_title(event)
      return 'event and release date' if event.released_on_event_day?
      return 'event date' if event.date

      'video release date'
    end

    def relive_data(event, width, height)
      data = { width: width, height: height, m3u8: event.relive['playlist'] }
      return data unless event.relive['sprites']

      data.merge!(
        sprites: event.relive['sprites']['url'],
        'sprites-n': event.relive['sprites']['n'],
        'sprites-cols': event.relive['sprites']['cols'],
        'sprites-interval': event.relive['sprites']['interval']
      )
    end

    def video_player_ivars(args = {})
      {
        height: '100%',
        width: '100%',
        event: @event
      }.merge(args)
    end

    def stretching
      'responsive'
    end
  end
end
