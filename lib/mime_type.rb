# frozen_string_literal: true

class MimeType
  AUDIO = %w(audio/ogg audio/mpeg audio/opus).freeze
  VIDEO = %w(video/mp4 video/ogg video/webm video/webm;codecs=av01).freeze
  STREAM = %w(application/dash+xml application/vnd.apple.mpegurl).freeze

  PREFERRED_VIDEO = %w(video/mp4 video/webm video/ogg).freeze

  SLIDES = %w(application/pdf video/mp4).freeze
  SUBTITLE = %w(application/x-subrip text/vtt).freeze

  class << self
    def all
      (VIDEO + AUDIO + SLIDES + SUBTITLE + STREAM).uniq.freeze
    end

    def mime_type_slug(mime_type)
      humanized(mime_type).to_param.downcase.freeze
    end

    def humanized(mime_type)
      case mime_type
      when 'video/mp4'
        'mp4'
      when 'video/webm'
        'webm'
      when 'video/webm;codecs=av01'
        'av1'
      when 'video/ogg'
        'ogg'
      when 'audio/mpeg'
        'mp3'
      when 'audio/opus'
        'opus'
      when 'application/x-subrip'
        'srt'
      when 'text/vtt'
        'vtt'
      when 'application/dash+xml'
        'mpd'
      when 'application/vnd.apple.mpegurl'
        'hls'
      when 'application/pdf'
        'pdf'
      else
        mime_type.split('/')[1]
      end
    end

    def display(mime_type)
      case mime_type
      when 'video/mp4'
        'MP4'
      when 'video/webm'
        'WebM'
      when 'video/webm;codecs=av01'
        'AV1'
      when 'video/ogg'
        'Ogg'
      when 'audio/mpeg'
        'MP3'
      when 'audio/opus'
        'Opus'
      when 'application/x-subrip'
        'SRT'
      when 'text/vtt'
        'WebVTT'
      when 'application/dash+xml'
        'mpd'
      when 'application/vnd.apple.mpegurl'
        'hls'
      when 'application/pdf'
        'PDF'
      else
        mime_type.split('/')[1].capitalize
      end
    end

    def is_video(mime_type)
      return mime_type.start_with?('video')
    end

    def is_audio(mime_type)
      return mime_type.start_with?('audio')
    end
  end

  RELEVANCE_COMPARATOR = ->(a,b) {
    if is_video(a) && ! is_video(b)
      -1
    elsif is_audio(a) && ! is_video(b) && ! is_audio(b)
      -1
    else
      a <=> b
    end
  }
end
