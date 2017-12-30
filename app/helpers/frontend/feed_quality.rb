module Frontend
  class FeedQuality
    HQ = 'hq'
    LQ = 'lq'
    MASTER = 'master'

    def self.display_name(quality)
      case quality&.downcase
        when HQ
          'high quality'
        when LQ
          'low quality'
        when MASTER
          'master'
        else
          ''
      end
    end

    def self.eventRecordingFilter(quality)
      case quality&.downcase
        when HQ then EventRecordingFilterHighQuality.new
        when LQ then EventRecordingFilterLowQuality.new
        when MASTER then EventRecordingFilterMaster.new
        else raise ArgumentError, "Invalid quality argument: #{quality}"
      end
    end
  end
end
