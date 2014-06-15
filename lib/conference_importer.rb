class ConferenceImporter
  def self.import(import_template)

    conference = Conference.create acronym: import_template.acronym,
      title: import_template.title,
      webgen_location: import_template.webgen_location,
      aspect_ratio: import_template.aspect_ratio,
      recordings_path: import_template.recordings_path,
      images_path: import_template.images_path,
      logo: import_template.logo

    import_template.recordings.each do |r|

      slug = File.basename r.filename, '.*'

      event = conference.events.create date: import_template.date,
        release_date: import_template.release_date,
        gif_filename: r.gif.try(:filename),
        poster_filename: r.poster.try(:filename),
        thumb_filename: r.thumb.try(:filename),
        title:  slug,
        slug: slug,
        guid: SecureRandom.hex(8)
      
      event.recordings.create filename: r.filename,
        folder: import_template.folder,
        state: 'downloaded',
        mime_type: import_template.mime_type,
        width: import_template.width,
        height: import_template.height

    end
  
  end
end
