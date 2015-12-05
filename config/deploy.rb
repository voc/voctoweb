# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'media-site'
set :repo_url, ENV['CAP_REPO']
set :branch, ENV['CAP_BRANCH']
set :user, ENV['CAP_USER']

# temporary deploy scripts, etc
set :tmp_dir, "/srv/www/#{fetch(:application)}/tmp"

# https://github.com/capistrano/rvm/
# set :rvm_type, :user                     # Defaults to: :auto
set :rvm_ruby_version, '2.2.3@media-site'

set :use_sudo,        false
set :stage,           :production
set :deploy_to,       "/srv/www/#{fetch(:application)}"
set :ssh_options,     forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub)
set :bundle_without,  %w(development test sqlite3).join(' ')
set :linked_files,    %w(config/settings.yml config/database.yml config/secrets.yml .env.production .ruby-version)
set :linked_dirs,     %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

# puma
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
set :puma_conf,       "#{shared_path}/config/puma.rb"

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  desc 'Start puma'
  task :start do
    on roles(:app) do
      within current_path do
        with rack_env: fetch(:puma_env) do
          execute :bundle, 'exec', :puma, "-C #{fetch(:puma_conf)} --daemon"
        end
      end
    end
  end

  %w[phased-restart restart].map do |command|
    desc "#{command} puma"
    task command do
      on roles(:app) do
        within current_path do
          with rack_env: fetch(:puma_env) do
            if test "[ -f #{fetch(:puma_pid)} ]"
              execute :bundle, 'exec', :pumactl, "-P #{fetch(:puma_pid)} #{command}"
            else
              # Puma is not running or state file is not present : Run it
              invoke 'puma:start'
            end
          end
        end
      end
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
