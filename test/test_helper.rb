ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/pride'
require 'sidekiq/testing'
require 'tilt/redcarpet'

Sidekiq::Logging.logger = nil

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  def run_background_jobs_immediately
    Sidekiq::Testing.inline! do
      yield
    end
  end

  def post_json(action, json)
    #post action, json, 'CONTENT_TYPE' => 'application/json'
    post action, headers: { 'CONTENT_TYPE' => 'application/json' }, params: json
  end

  def create_test_file(target, source = 'audio.mp3')
    source = File.join(Rails.root, 'test', 'fixtures', source)
    FileUtils.copy source, target

    File.join(Rails.root, target)
  end
end
