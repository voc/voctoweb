# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'media-site'
set :repo_url, ENV['CAP_REPO']

# Default branch is :master
set :branch, ENV['CAP_BRANCH']

set :user, ENV['CAP_USER']

# temporary deploy scripts, etc
set :tmp_dir, "/srv/www/#{fetch(:application)}/tmp"

# https://github.com/capistrano/rvm/
# set :rvm_type, :user                     # Defaults to: :auto
set :rvm_ruby_version, '2.2.3@media-site'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# taken from: https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma
set :puma_threads,    [4, 16]
set :puma_workers,    3

# Don't change these unless you know what you're doing
# Default value for :pty is false
set :pty,             true
set :use_sudo,        false
set :stage,           :production
# set :deploy_via,      :remote_cache
set :deploy_to,       "/srv/www/#{fetch(:application)}/apps/#{fetch(:application)}"
set :puma_bind,       ["unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock", 'tcp://127.0.0.1:4080']
set :puma_conf,       "#{shared_path}/config/puma.rb"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub)
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord
set :bundle_without, %w(development test sqlite3).join(' ')

# Default value for :linked_files is []
set :linked_files, %w(config/initializers/media_backend.rb config/database.yml config/secrets.yml .env.production .ruby-version)
# Default value for linked_dirs is []
set :linked_dirs,  %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :finishing,    :compile_assets
  after :finishing,    :cleanup
  after :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
