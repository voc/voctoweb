require 'test_helper'
require 'rake'

class RecordingsTaskTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/recordings'
    Rake::Task.define_task(:environment)
    @recording = create(:recording, size: 0)
    @filesizes_path = Rails.root.join('tmp', 'filesizes_test.json')
  end

  teardown do
    Rake::Task['voctoweb:recordings:update_sizes'].reenable
    File.delete(@filesizes_path) if File.exist?(@filesizes_path)
    ENV.delete('FILESIZES_PATH')
  end

  def with_filesizes(data)
    File.write(@filesizes_path, data.to_json)
    ENV['FILESIZES_PATH'] = @filesizes_path.to_s
  end

  test 'update_sizes rake task updates recording size from the manifest' do
    with_filesizes(@recording.url => 562902679)

    assert_output(/#{@recording.filename}: 562902679 bytes/) do
      Rake::Task['voctoweb:recordings:update_sizes'].invoke
    end

    @recording.reload
    assert_equal 562902679, @recording.size
  end

  test 'update_sizes rake task leaves size untouched when the manifest has no entry' do
    with_filesizes('https://cdn.media.ccc.de/some/other/file.mp4' => 123)

    assert_output(/#{@recording.filename}: not found/) do
      Rake::Task['voctoweb:recordings:update_sizes'].invoke
    end

    @recording.reload
    assert_equal 0, @recording.size
  end

  test 'update_sizes rake task ignores a zero size entry' do
    with_filesizes(@recording.url => 0)

    assert_output(/#{@recording.filename}: not found/) do
      Rake::Task['voctoweb:recordings:update_sizes'].invoke
    end

    @recording.reload
    assert_equal 0, @recording.size
  end
end
