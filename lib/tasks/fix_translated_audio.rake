namespace :voctoweb do
  namespace :feeds do
    desc 'Compare audio feeds before/after fixing mis-flagged translated recordings for a conference'
    task :check_translated, [:acronym] => :environment do |_t, args|
      acronym = args[:acronym]
      abort "Usage: rake voctoweb:feeds:check_translated[ACRONYM]" unless acronym

      conference = Conference.find_by(acronym: acronym)
      abort "Conference '#{acronym}' not found" unless conference

      mis_flagged = Recording.joins(:event)
        .where(events: { conference_id: conference.id })
        .where(mime_type: MimeType::AUDIO, translated: true)
        .where.not("recordings.folder ILIKE '%transla%'")

      if mis_flagged.empty?
        puts "No mis-flagged audio recordings found for #{acronym}."
        next
      end

      puts "#{mis_flagged.count} mis-flagged audio recording(s):"
      mis_flagged.each do |r|
        puts "  ##{r.id} folder=#{r.folder} lang=#{r.language} file=#{r.filename}"
      end
      puts

      # Generate feeds before fix
      Feed::FolderWorker.new.perform(conference.id)

      audio_feeds = WebFeed.where(key: 'podcast_folder').where("kind LIKE ?", "#{conference.acronym}%")
      audio_slugs = MimeType::AUDIO.map { |mt| MimeType.mime_type_slug(mt) }
      audio_feeds = audio_feeds.select { |f| audio_slugs.any? { |slug| f.kind.end_with?(slug) } }

      before_counts = audio_feeds.to_h { |f| [f.kind, f.content.scan(/<item>/).count] }

      # Apply fix
      mis_flagged_ids = mis_flagged.pluck(:id)
      Recording.where(id: mis_flagged_ids).update_all(translated: false)

      # Regenerate feeds after fix
      Feed::FolderWorker.new.perform(conference.id)
      audio_feeds.each(&:reload)

      after_counts = audio_feeds.to_h { |f| [f.kind, f.content.scan(/<item>/).count] }

      puts "Feed comparison:"
      before_counts.each do |kind, before_count|
        after_count = after_counts[kind]
        puts "  #{kind}: #{before_count} -> #{after_count} items"
      end
      puts

      print "Keep the fix? [y/N] "
      if $stdin.gets.strip.downcase == 'y'
        puts "Fix applied."
      else
        Recording.where(id: mis_flagged_ids).update_all(translated: true)
        Feed::FolderWorker.new.perform(conference.id)
        puts "Rolled back."
      end
    end

    desc 'Fix all conferences with empty audio feeds due to mis-flagged translated recordings'
    task fix_empty_audio_feeds: :environment do
      empty_feed_ids = Conference.joins(events: :recordings)
        .where(recordings: { mime_type: MimeType::AUDIO })
        .where.not(id: Conference.joins(events: :recordings)
          .where(recordings: { mime_type: MimeType::AUDIO, translated: false })
          .select(:id))
        .distinct

      mis_flagged = Recording.joins(:event)
        .where(events: { conference_id: empty_feed_ids })
        .where(mime_type: MimeType::AUDIO, translated: true)
        .where.not("recordings.folder ILIKE '%transla%'")

      if mis_flagged.empty?
        puts "No conferences with mis-flagged empty audio feeds found."
        next
      end

      by_conference = mis_flagged.includes(event: :conference).group_by { |r| r.event.conference }

      puts "#{by_conference.size} conference(s) with empty audio feeds to fix:\n\n"
      by_conference.each do |conference, recs|
        puts "  #{conference.acronym} (#{recs.size} recording(s))"
        recs.each do |r|
          puts "    ##{r.id} folder=#{r.folder} lang=#{r.language} file=#{r.filename}"
        end
      end
      puts

      print "Fix all #{mis_flagged.count} recordings and regenerate feeds? [y/N] "
      unless $stdin.gets.strip.downcase == 'y'
        puts "Aborted."
        next
      end

      mis_flagged_ids = mis_flagged.pluck(:id)
      Recording.where(id: mis_flagged_ids).update_all(translated: false)
      puts "Fixed #{mis_flagged_ids.size} recordings."

      by_conference.each_key do |conference|
        Feed::FolderWorker.new.perform(conference.id)
        puts "  Regenerated feeds for #{conference.acronym}"
      end

      puts "Done."
    end

    desc 'Fix all mis-flagged translated audio recordings and regenerate all feeds'
    task fix_all_translated_audio: :environment do
      mis_flagged = Recording.where(mime_type: MimeType::AUDIO, translated: true)
        .where.not("recordings.folder ILIKE '%transla%'")

      if mis_flagged.empty?
        puts "No mis-flagged audio recordings found."
        next
      end

      affected_conference_ids = mis_flagged.joins(:event).select('DISTINCT events.conference_id')
      conferences = Conference.where(id: affected_conference_ids).order(:acronym)

      puts "#{mis_flagged.count} mis-flagged audio recording(s) across #{conferences.size} conference(s):\n\n"
      conferences.each do |c|
        count = mis_flagged.joins(:event).where(events: { conference_id: c.id }).count
        puts "  #{c.acronym} (#{count})"
      end
      puts

      print "Fix all and regenerate feeds? [y/N] "
      unless $stdin.gets.strip.downcase == 'y'
        puts "Aborted."
        next
      end

      fixed = mis_flagged.update_all(translated: false)
      puts "Fixed #{fixed} recordings."

      puts "Regenerating feeds..."
      conferences.each do |c|
        Feed::FolderWorker.new.perform(c.id)
        puts "  #{c.acronym}"
      end

      puts "Done."
    end
  end
end
