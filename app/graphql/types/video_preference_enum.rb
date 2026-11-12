module Types
  class VideoPreferenceEnum < Types::BaseEnum
    description "Preferred video format"
    value "MP4", "MPEG-4 video format", value: "video/mp4"
    value "AV1", "AV1 video codec (WebM container)", value: "video/webm;codecs=av01"
    value "DASH", "DASH streaming format", value: "application/dash+xml"
    value "WEBM", "WebM video format", value: "video/webm"
  end
end
