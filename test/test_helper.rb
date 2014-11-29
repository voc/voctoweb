ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

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

    File.join(Rails.root, target)
  end

end
