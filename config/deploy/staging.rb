server ENV['CAP_HOST'], roles: %w{app db web}, primary: true, port: ENV['CAP_PORT']
set :deploy_to,       "/srv/media/#{fetch(:application)}"
set :tmp_dir,         "/srv/media/#{fetch(:application)}/tmp"
