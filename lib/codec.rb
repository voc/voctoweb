# frozen_string_literal: true

class Codec
  AUDIO = %w(mp3 opus).freeze
  VIDEO = %w(h264 vp8 vp9 av1).freeze

  PREFERRED_VIDEO = %w(h264 av1).freeze

  class << self
    def all
      (VIDEO + AUDIO).uniq.freeze
    end

    def codec_slug(codec)
      humanized_codec(codec).to_param.downcase.freeze
    end

    def humanized_codec(codec)
      case codec
      when 'opus'
        'Opus'
      else
        codec.uppercase
      end
    end

    def is_video(codec)
      return VIDEO.include? codec
    end

    def is_audio(codec)
      return AUDIO.include? codec
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
