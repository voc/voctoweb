# frozen_string_literal: true
class MimeType
  AUDIO = %w(audio/ogg audio/mpeg audio/opus).freeze
  VIDEO = %w(video/mp4 video/ogg video/webm).freeze

  PREFERRED_VIDEO = %w(video/mp4 video/webm video/ogg).freeze

  SUBTITLE = %w(application/x-subrip)

  class << self
    def all
      (VIDEO + AUDIO + SUBTITLE).uniq.freeze
    end

    def mime_type_slug(mime_type)
      humanized_mime_type(mime_type).to_param.downcase.freeze
    end

    def humanized_mime_type(mime_type)
      case mime_type
      when 'video/mp4'
        'mp4'
      when 'video/webm'
        'webm'
      when 'video/ogg'
        'ogg'
      when 'audio/mpeg'
        'mp3'
      else
        mime_type.split('/'.freeze)[1]
      end
    end
  end
end
