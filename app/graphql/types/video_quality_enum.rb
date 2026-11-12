module Types
  class VideoQualityEnum < Types::BaseEnum
    description "Preferred video quality tier"
    value "HQ", "High quality", value: FeedQuality::HQ
    value "LQ", "Low quality", value: FeedQuality::LQ
    value "ORIGINAL", "Original master quality, largest file size", value: FeedQuality::MASTER
  end
end
