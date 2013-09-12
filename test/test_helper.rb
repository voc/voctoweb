ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  ActiveRecord::Migration.check_pending!

  TMP_DIR = 'tmp/tests'

  def set_config_folders_to_tmp
    MediaBackend::Application.config.folders[:recordings_base_dir] = File.join(TMP_DIR, 'rec')
    MediaBackend::Application.config.folders[:images_base_dir] = File.join(TMP_DIR, 'img')
    MediaBackend::Application.config.folders[:webgen_base_dir] = File.join(TMP_DIR, 'src')
  end

  # Add more helper methods to be used by all tests here...
  def run_background_jobs_immediately
    delay_jobs = Delayed::Worker.delay_jobs
    Delayed::Worker.delay_jobs = false
    yield
    Delayed::Worker.delay_jobs = delay_jobs
  end

  def post_json(action, json)
    post action, json, "CONTENT_TYPE" => "application/json"
  end

  def create_test_file(target, source="audio.mp3")
    source = File.join(Rails.root, 'test', 'fixtures', source)
    FileUtils.copy source, target
  end

end
