module ViewHelper

  # TODO move logos to c.get_images_path, fix c.logo and use c.get_images_url here
  def show_logo_url(path)
    return nil if path.nil?
    "#{path} (#{File.join(MediaBackend::Application.config.staticURL, path)})"
  end

  def show_folder(label: 'Path', path: '/')
    return nil if label.empty?
    if File.readable? path
      "#{label} (#{path})"
    else
      "#{label} (missing: #{path})"
    end
  end

  def show_event_folder(event, filename)
    label = event.send(filename)
    path = File.join(event.conference.get_images_path, label)
    show_folder label: label, path: path
  end

  def show_recording_path(recording)
    show_folder label: recording.filename ,path: recording.get_recording_path
  end

  def show_recording_url(recording)
    "(#{File.join(MediaBackend::Application.config.cdnURL, 
        recording.event.conference.recordings_path, recording.get_recording_webpath)})"
  end

  def job_object(job)
    begin
      YAML.load(job.handler).object.class.to_s
    rescue
      ""
    end
  end

  def job_method(job)
    begin
      YAML.load(job.handler).method_name.to_s
    rescue
      ""
    end
  end

end
