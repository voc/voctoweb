# config valid only for current version of Capistrano
lock '3.17.1'

set :application, 'media-site'
set :repo_url, ENV['CAP_REPO']
set :branch, ENV['CAP_BRANCH']
set :user, ENV['CAP_USER']

# temporary deploy scripts, etc
set :tmp_dir, "/srv/media/#{fetch(:application)}/tmp"

# https://github.com/capistrano/rvm/
# set :rvm_type, :user                     # Defaults to: :auto
set :rvm_ruby_version, '3.0.3'

set :use_sudo,        false
set :stage,           :production
set :deploy_to,       "/srv/media/#{fetch(:application)}"
set :ssh_options,     forward_agent: false, user: fetch(:user)
set :bundle_without,  %w(development test sqlite3).join(' ')
set :linked_files,    %w(config/settings.yml config/database.yml config/secrets.yml .env.production .ruby-version)
set :linked_dirs,     %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

# puma
set :puma_pid,        -> { "#{shared_path}/tmp/pids/puma.pid" }
set :puma_env,        -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
set :puma_conf,       -> { "#{shared_path}/config/puma.rb" }

# sidekiq
set :init_system, :systemd
set :service_unit_name, "voctoweb-sidekiq.service"

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
          execute :bundle, 'exec', :puma, "-C #{fetch(:puma_conf)}"
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
      before 'deploy:restart' #, 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Notify IRC about deployment'
  task :notify do
    if ENV['MQTT_URL']
      MQTT::Client.connect(ENV['MQTT_URL']) do |c|
        c.publish('/voc/alert', %'{"component": "media-deploy", "msg": "#{revision_log_message} on #{ENV['CAP_HOST']}", "level": "info"}')
      end
    end
  end

  after :finishing,    :compile_assets
  after :finishing,    :cleanup
  after :finishing,    :restart
  after :finishing,    :notify
end

namespace :fixtures do
  set :fixtures_path, 'tmp/fixtures_dump'

  desc 'Download fixtures'
  task :download do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), fixtures_path: fetch(:fixtures_path) do
          execute :mkdir, '-p', fetch(:fixtures_path)
          execute :rake, 'db:fixtures:dump'
        end
      end
      download!("#{current_path}/#{fetch(:fixtures_path)}", 'tmp/', recursive: true)
    end
  end

  desc 'Upload fixtures'
  task :upload do
    on roles(:app) do
      within release_path do
        execute :rm, "-rf #{current_path}/#{fetch(:fixtures_path)}"
      end
      upload!(fetch(:fixtures_path), "#{current_path}/tmp/", recursive: true)
    end
  end
end

namespace :elasticsearch do
  desc 'Create initial index'
  task :create_index do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, "exec rails runner Event.__elasticsearch__.create_index! force: true"
        end
      end
    end
  end

  desc 'Update elasticsearch'
  task :update do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, "exec rails runner Event.import"
        end
      end
    end
  end
end
