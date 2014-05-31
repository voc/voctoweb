namespace :db do
  desc 'Dump fixtures from database'
  task dump_fixtures: :environment do
    fixtures_dir = ENV['fixtures_dir'] || 'test/fixtures'
    sql = 'SELECT * FROM %s'
    skip_tables = %w{schema_info schema_migrations delayed_jobs sessions}
    ActiveRecord::Base.establish_connection(Rails.env)
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
