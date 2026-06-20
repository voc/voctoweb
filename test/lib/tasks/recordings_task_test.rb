require 'test_helper'
require 'rake'
require 'httpx'

class RecordingsTaskTest < ActiveSupport::TestCase
  class MockHTTPXResponse
    def initialize(status, headers, reason = "OK")
      @status = status
      @headers = headers
      @reason = reason
    end

    def is_a?(klass)
      klass == ::HTTPX::Response || super
    end

    attr_reader :status, :headers, :reason

    def body
      ""
    end
  end

  setup do
    Rake.application.rake_require 'tasks/recordings'
    Rake::Task.define_task(:environment)
    @recording = create(:recording, size: 0)
  end

  teardown do
    Rake::Task['voctoweb:recordings:update_sizes'].reenable
  end

  test 'update_sizes rake task updates recording size' do
    mock_response = MockHTTPXResponse.new(200, { 'content-length' => '562902679' })

    HTTPX::Session.class_eval do
      alias_method :original_request, :request
      define_method(:request) do |*args|
        mock_response
      end
    end

    begin
      # Capture/suppress output for cleaner test runs
      assert_output(/Success: 562902679 bytes/) do
        Rake::Task['voctoweb:recordings:update_sizes'].invoke
      end
    ensure
      HTTPX::Session.class_eval do
        alias_method :request, :original_request
        remove_method :original_request
      end
    end

    @recording.reload
    assert_equal 562902679, @recording.size
  end

  test 'update_sizes rake task follows redirection' do
    redirect_response = MockHTTPXResponse.new(302, { 'location' => 'https://example.com/final.mp4' }, "Found")
    success_response = MockHTTPXResponse.new(200, { 'content-length' => '987654321' }, "OK")

    calls = []

    HTTPX::Session.class_eval do
      alias_method :original_request, :request
      define_method(:request) do |request, *args|
        calls << request.uri.to_s
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
      HTTPX::Session.class_eval do
        alias_method :request, :original_request
        remove_method :original_request
      end
    end

    @recording.reload
    assert_equal 987654321, @recording.size
    assert_equal 2, calls.size
  end

  test 'update_sizes rake task retries on non-404 failure and then succeeds' do
    failure_response = MockHTTPXResponse.new(500, {}, "Internal Server Error")
    success_response = MockHTTPXResponse.new(200, { 'content-length' => '112233' }, "OK")

    calls = 0

    HTTPX::Session.class_eval do
      alias_method :original_request, :request
      define_method(:request) do |*args|
        calls += 1
        if calls <= 2
          failure_response
        else
          success_response
        end
      end
    end

    begin
      assert_output(/Success: 112233 bytes/) do
        Rake::Task['voctoweb:recordings:update_sizes'].invoke
      end
    ensure
      HTTPX::Session.class_eval do
        alias_method :request, :original_request
        remove_method :original_request
      end
    end

    @recording.reload
    assert_equal 112233, @recording.size
    assert_equal 3, calls
  end

  test 'update_sizes rake task does not retry on 404' do
    not_found_response = MockHTTPXResponse.new(404, {}, "Not Found")

    calls = 0

    HTTPX::Session.class_eval do
      alias_method :original_request, :request
      define_method(:request) do |*args|
        calls += 1
        not_found_response
      end
    end

    begin
      assert_output(/Querying size for #{@recording.filename}... Failed/) do
        Rake::Task['voctoweb:recordings:update_sizes'].invoke
      end
    ensure
      HTTPX::Session.class_eval do
        alias_method :request, :original_request
        remove_method :original_request
      end
    end

    @recording.reload
    assert_equal 0, @recording.size
    assert_equal 1, calls
  end
end
