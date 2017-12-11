class MimeTypesToFlags < ActiveRecord::Migration[4.2]
  def change
    html5 = %w(vnd.voc/mp4-web vnd.voc/webm-web)
    Recording.find_each do |recording|
      next unless recording.valid?
      recording.hd_quality = hd?(recording.mime_type)
      recording.html5 = html5.include?(recording.mime_type)
      recording.mime_type = display_mime_type(recording.mime_type)
      recording.save!
    end
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
      true
    end
  end
end
