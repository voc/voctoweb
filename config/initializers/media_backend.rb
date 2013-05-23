MediaBackend::Application.configure do
    config.folders = { 
      recordings_base_dir: '/srv/recordings/cdn',
      images_base_dir: '/srv/www/cdn',
      webgen_base_dir: '/srv/www/webgen/src/browse',
      tmp_dir: '/tmp'
    }

    config.mime_type_folder_mappings = {
      'audio/mp3' => 'mp3',
      'video/mp4' => 'mp4',
    }
end
