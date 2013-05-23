MediaBackend::Application.configure do
    config.folders = { 
      recordings_base_dir: '/srv/ftp',  
      images_base_dir: '/srv/www/media.ccc.de/out/media',  
    }
    config.mime_type_folder_mappings = {
      'audio/mp3' => 'mp3',
      'video/mp4' => 'mp4',
    }
end
