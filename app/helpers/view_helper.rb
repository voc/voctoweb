module ViewHelper
  def show_recording_url(recording)
    "(#{recording.get_recording_url})"
  end

  def show_folder(label: 'Path', path: '/')
    return nil if label.empty?
    "#{label} (#{path})"
  end

  def show_event_folder(event, filename)
    label = event.send(filename)
    path = File.join(event.conference.get_images_url, label)
    show_folder label: label, path: path
  end

  def show_recording_path(recording)
    show_folder label: recording.filename, path: recording.get_recording_url
  end
end
