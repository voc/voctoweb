namespace :db do
  namespace :fixtures do
    desc 'Dump fixtures from database'
    task :dump, [:include_private] => [:environment] do |t, args|
      fixtures_dir = ENV['FIXTURES_PATH'] || 'test/fixtures'
      sql = 'SELECT * FROM %s'

      skip_tables = %w(schema_info schema_migrations sessions recording_views active_admin_comments ar_internal_metadata)
      skip_tables += %w(api_keys admin_users) unless args[:include_private]

      ActiveRecord::Base.establish_connection
      i = '000'
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table|
        File.open(File.join(fixtures_dir, "#{table}.yml"), 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table)
          file.write data.inject({}) { |hash, record|
            hash["#{table}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  end
end
