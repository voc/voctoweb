class MimeType
  HTML5 = %w[audio/ogg audio/mpeg audio/opus video/mp4 video/ogg video/webm vnd.voc/h264-lq vnd.voc/h264-sd vnd.voc/webm-hd vnd.voc/h264-hd]
  PREFERRED_VIDEO = %w[vnd.voc/h264-hd vnd.voc/h264-lq video/mp4 vnd.voc/h264-sd vnd.voc/webm-hd video/webm video/ogg]
  WEB_PREFERRED_VIDEO = %w[vnd.voc/mp4-web vnd.voc/webm-web vnd.voc/h264-hd vnd.voc/h264-lq video/mp4 vnd.voc/h264-sd vnd.voc/webm-hd video/webm video/ogg]

  class << self

    def mime_type_slug(mime_type)
      humanized_mime_type(mime_type).to_param.downcase
    end

    def display_mime_type(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'
        'video/mp4'
      when 'vnd.voc/h264-sd'
        'video/mp4'
      when 'vnd.voc/h264-hd'
        'video/mp4'
      when 'vnd.voc/mp4-web'
        'video/mp4'
      when 'vnd.voc/webm-hd'
        'video/webm'
      when 'vnd.voc/webm-web'
        'video/webm'
      else
        mime_type
      end
    end

    def hd?(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'
        false
      when 'vnd.voc/h264-sd'
        false
      when 'vnd.voc/h264-hd'
        true
      when 'vnd.voc/webm-hd'
        true
      else
        nil
      end
    end

    def humanized_mime_type(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'
        'MP4 (LQ)'
      when 'vnd.voc/h264-sd'
        'MP4 (SD)'
      when 'vnd.voc/h264-hd'
        'MP4 (HD)'
      when 'vnd.voc/webm-hd'
        'WEBM (HD)'
      when 'vnd.voc/webm-web'
        'WEBM (html5)'
      when 'vnd.voc/mp4-web'
        'MP4 (html5)'
      when 'audio/mpeg'
        'MP3'
      else
        mime_type.split('/')[1]
      end
    end

  end

end
