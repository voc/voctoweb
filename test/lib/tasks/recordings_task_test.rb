require 'test_helper'
require 'rake'

class RecordingsTaskTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/recordings'
    Rake::Task.define_task(:environment)
    @recording = create(:recording, size: 0)
  end

  teardown do
    Rake::Task['voctoweb:recordings:update_sizes'].reenable
  end

  test 'update_sizes rake task updates recording size' do
    mock_response = Net::HTTPSuccess.new('1.1', '200', 'OK')
    mock_response.add_field('content-length', '562902679')

    Net::HTTP.class_eval do
      alias_method :original_request_head, :request_head
      define_method(:request_head) do |*args|
        mock_response
      end
    end

    begin
      # Capture/suppress output for cleaner test runs
      assert_output(/Success: 562902679 bytes/) do
        Rake::Task['voctoweb:recordings:update_sizes'].invoke
      end
    ensure
      Net::HTTP.class_eval do
        alias_method :request_head, :original_request_head
        remove_method :original_request_head
      end
    end

    @recording.reload
    assert_equal 562902679, @recording.size
  end

  test 'update_sizes rake task follows redirection' do
    redirect_response = Net::HTTPRedirection.new('1.1', '302', 'Found')
    redirect_response.add_field('location', 'https://example.com/final.mp4')

    success_response = Net::HTTPSuccess.new('1.1', '200', 'OK')
    success_response.add_field('content-length', '987654321')

    calls = []

    Net::HTTP.class_eval do
      alias_method :original_request_head, :request_head
      define_method(:request_head) do |*args|
        calls << args.first
        if calls.size == 1
          redirect_response
        else
          success_response
        end
      end
    end

    begin
      assert_output(/Success: 987654321 bytes/) do
        Rake::Task['voctoweb:recordings:update_sizes'].invoke
      end
    ensure
      Net::HTTP.class_eval do
        alias_method :request_head, :original_request_head
        remove_method :original_request_head
      end
    end

    @recording.reload
    assert_equal 987654321, @recording.size
    assert_equal 2, calls.size
  end
end
