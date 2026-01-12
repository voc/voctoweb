# frozen_string_literal: true

# Feed quality levels for podcast/RSS feed generation
class FeedQuality
  HQ = 'hq'
  LQ = 'lq'
  MASTER = 'master'

  def self.all
    [HQ, LQ, MASTER]
  end

  def self.valid?(quality)
    all.include?(quality)
  end

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
end
