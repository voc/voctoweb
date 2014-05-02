namespace :media do

  task :default => :import_webgen

  desc "import webgen videopage yaml files into database."

  task :import_webgen => :environment do |t,args|

    webgen_dir = MediaBackend::Application.config.folders[:webgen_base_dir]
    if not ENV['dir'] and not File.readable? webgen_dir
      puts "Usage: rake media:import_webgen dir=/srv/media-webgen/src/"
      exit
    end

    if File.readable? ENV['dir']
      dir = ENV['dir']
    else
      dir = webgen_dir
    end
    require "import_webgen_yaml.rb"
    importer = Import::WebgenImporter.new(dir)
    importer.import
  end

end
