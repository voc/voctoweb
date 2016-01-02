# frozen_string_literal: true
class MimeType
  AUDIO = %w(audio/ogg audio/mpeg audio/opus).freeze
  VIDEO = %w(video/mp4 video/ogg video/webm).freeze

  PREFERRED_VIDEO = %w(vnd.voc/h264-hd vnd.voc/h264-lq video/mp4 vnd.voc/h264-sd vnd.voc/webm-hd video/webm video/ogg).freeze

  SUBTITLE = %w(application/x-subrip)

  class << self
    def all
      (VIDEO + AUDIO + SUBTITLE).uniq.freeze
    end

    def mime_type_slug(mime_type)
      humanized_mime_type(mime_type).to_param.downcase.freeze
    end

    # TODO this will be just mime_type one day?
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
        mime_type.split('/'.freeze)[1]
      end
    end
  end
end
