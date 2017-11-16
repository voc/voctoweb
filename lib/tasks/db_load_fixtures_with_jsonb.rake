namespace :db do
  namespace :fixtures do
    desc 'Load fixtures into database, converting jsonb'
    task :load_jsonb, [:include_private] => [:environment] do |t, args|
      Rake::Task["db:fixtures:load"].execute

      ActiveRecord::Base.establish_connection
      Conference.all.each { |c| c.update_column(:metadata, JSON.parse('{"subtitles":true}')) if c.metadata == "\"{\\\"subtitles\\\":true}\"" }
      Conference.all.each { |c| c.update_column(:metadata, JSON.parse('{}')) if c.metadata == "\"{}\"" }

      Conference.all.each { |c| c.update_column(:metadata, JSON.parse(c.metadata)) if c.metadata.is_a? String }
      Conference.all.each { |c| c.update_column(:streaming, JSON.parse(c.streaming)) if c.streaming.is_a? String }

      Event.all.each { |e| e.update_column(:metadata, JSON.parse(e.metadata)) if e.metadata.is_a? String }
    end
  end
end
