class FillRecordingsFolderFromMimeTypes < ActiveRecord::Migration[4.2]

  def up
    mappings = {
      'application/ogg'   => 'ogg',
      'application/vnd.rn-realmedia' => 'realmedia',
      'audio/ogg'         => 'ogg',
      'audio/opus'        => 'opus',
      'audio/mpeg'        => 'mp3',
      'audio/x-wav'       => 'wav',
      'video/mp4'         => 'mp4',
      'vnd.voc/h264-hd'   => 'mp4-hd',
      'vnd.voc/h264-lq'   => 'mp4-lq',
      'video/ogg'         => 'ogg',
      'video/quicktime'   => 'qt',
      'video/webm'        => 'webm',
      'video/x-matroska'  => 'mkv',
      'video/x-msvideo'   => 'avi',
    }
   
    Recording.all.each do |r|
      next if r.mime_type.empty?
      r.folder = mappings[r.mime_type] || ""
      r.save!
    end
  end

  def down
    Recording.all.each do |r|
      r.folder = ''
      r.save!
    end
  end
end
