server ENV['CAP_HOST'], roles: %w{app db web}, primary: true, port: ENV['CAP_PORT']
set :deploy_to,       "/srv/media/#{fetch(:application)}"
set :tmp_dir,         "/srv/media/#{fetch(:application)}/tmp"

namespace :fixtures do
  task :apply do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), FIXTURES_PATH: fetch(:fixtures_path) do
          execute :rake, 'db:fixtures:load'
        end
      end
    end
  end
end
