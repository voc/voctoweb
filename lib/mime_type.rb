class MimeType
  HTML5_VIDEO = %w(vnd.voc/mp4-web vnd.voc/webm-web video/mp4 vnd.voc/h264-lq vnd.voc/h264-hd vnd.voc/h264-sd vnd.voc/webm-hd video/ogg video/webm).map!(&:freeze).freeze
  AUDIO = %w(audio/ogg audio/mpeg audio/opus).map!(&:freeze).freeze

  PREFERRED_VIDEO = %w(vnd.voc/h264-hd vnd.voc/h264-lq video/mp4 vnd.voc/h264-sd vnd.voc/webm-hd video/webm video/ogg).map!(&:freeze).freeze
  WEB_PREFERRED_VIDEO = %w(vnd.voc/mp4-web vnd.voc/webm-web vnd.voc/h264-hd vnd.voc/h264-lq video/mp4 vnd.voc/h264-sd vnd.voc/webm-hd video/webm video/ogg).map!(&:freeze).freeze

  class << self
    def all
      (HTML5_VIDEO + AUDIO).uniq.freeze
    end

    def mime_type_slug(mime_type)
      humanized_mime_type(mime_type).to_param.downcase.freeze
    end

    def display_mime_type(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'.freeze
        'video/mp4'.freeze
      when 'vnd.voc/h264-sd'.freeze
        'video/mp4'.freeze
      when 'vnd.voc/h264-hd'.freeze
        'video/mp4'.freeze
      when 'vnd.voc/mp4-web'.freeze
        'video/mp4'.freeze
      when 'vnd.voc/webm-hd'.freeze
        'video/webm'.freeze
      when 'vnd.voc/webm-web'.freeze
        'video/webm'.freeze
      else
        mime_type
      end
    end

    def hd?(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'.freeze
        false
      when 'vnd.voc/h264-sd'.freeze
        false
      when 'vnd.voc/h264-hd'.freeze
        true
      when 'vnd.voc/webm-hd'.freeze
        true
      end
    end

    def humanized_mime_type(mime_type)
      case mime_type
      when 'vnd.voc/h264-lq'.freeze
        'MP4 (LQ)'.freeze
      when 'vnd.voc/h264-sd'.freeze
        'MP4 (SD)'.freeze
      when 'vnd.voc/h264-hd'.freeze
        'MP4 (HD)'.freeze
      when 'vnd.voc/webm-hd'.freeze
        'WEBM (HD)'.freeze
      when 'vnd.voc/webm-web'.freeze
        'WEBM (html5)'.freeze
      when 'vnd.voc/mp4-web'.freeze
        'MP4 (html5)'.freeze
      when 'audio/mpeg'
        'MP3'.freeze
      else
        mime_type.split('/'.freeze)[1]
      end
    end
  end
end
