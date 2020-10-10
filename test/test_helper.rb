ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/pride'
require 'sidekiq/testing'
require 'tilt/redcarpet'
require 'rexml/document'
require 'sidekiq/testing'

Sidekiq.logger.level = Logger::FATAL

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  def run_background_jobs_immediately
    Sidekiq::Testing.inline! do
      yield
    end
  end

  def post_json(action, json)
    post action, headers: { 'CONTENT_TYPE' => 'application/json' }, params: json
  end

  def get_json(action, json)
    get action, headers: { 'CONTENT_TYPE' => 'application/json' }, params: json
  end

  def create_test_file(target, source = 'audio.mp3')
    source = File.join(Rails.root, 'test', 'fixtures', source)
    FileUtils.copy source, target

    File.join(Rails.root, target)
  end

  def xml_rss_items(xml)
    doc = REXML::Document.new(xml)
    items = []
    doc.elements.each("/rss/channel/item") { |ev| items << ev }
    items
  end
end
