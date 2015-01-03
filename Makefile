quick:
	git stash
	git pull
	pumactl -p tmp/pids/server.pid restart

update:
	git stash
	git pull
	bundle install
	RAILS_ENV=production rake db:migrate
	RAILS_ENV=production bin/delayed_job stop
	kill `cat tmp/pids/server.pid`
	RAILS_ENV=production bin/delayed_job start

testdata_dump_live:
	umask 077
	RAILS_ENV=production rake db:dump_fixtures
	tar cfz /tmp/media-backend-fixtures${TODAY}.tar.gz test/fixtures/{active_admin_comments.yml,conferences.yml,events.yml,import_templates.yml,news.yml,recordings.yml,schedule.xml}

testdata_create_tar:
	tar xfz media-backend-fixtures${TODAY}.tar.gz
	mv -i db/development.sqlite3 db/development_${TODAY}.sqlite3
	bundle exec rake db:setup
	rm -f test/fixtures/{admin_users.yml,api_keys.yml,recording_views.yml}
	bundle exec rake db:fixtures:load
	bundle exec rails runner 'Conference.all.select { |c| not %w{sigint13 31c3 20c3 camp2011}.include? c.acronym }.each { |c| c.destroy }'
	sqlite3 db/development.sqlite3 .dump | gzip > testdata.sql.gz



