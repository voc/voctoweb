MediaBackend::Application.configure do
    config.folders = { 
      recordings_base_dir: '/srv/recordings/cdn',
      images_base_dir: '/srv/www/cdn',
      webgen_base_dir: '/srv/www/webgen/src/browse',
      tmp_dir: '/tmp'
    }

    config.mime_type_folder_mappings = {
      'application/ogg'   => 'ogg',
      'application/vnd.rn-realmedia' => 'realmedia',
      'audio/mpeg'        => 'mp3',
      'audio/x-wav'       => 'wav',
      'video/mp4'         => 'mp4',
      'video/quicktime'   => 'qt',
      'video/webm'        => 'webm',
      'video/x-matroska'  => 'mkv',
      'video/x-msvideo'   => 'avi',
    }
end
