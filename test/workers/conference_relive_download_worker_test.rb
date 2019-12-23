require 'test_helper'

class ConferenceReliveDownloadWorkerTest < ActiveSupport::TestCase
  def relive_toc
    [
      {
        project: 'gpn18',
        media_conference_id: @conference.id,
        index_url: 'file:///test/fixtures/relive-gpn18.json',
        updated_at: Time.now.to_i
      },
      {
        project: 'djangocon2018',
        media_conference_id: @old_conference.id,
        #index_url: '//live.ber.c3voc.de/relive/djangocon2018/index.json',
        index_url: '//c3voc.de/share/api-examples/relive.json',
        updated_at: Time.now.ago(3.days).to_i
      },
      {
        project: 'raumfahrttag',
        index_url: '//live.ber.c3voc.de/relive/raumfahrttag/index.json',
        updated_at: 1530644654
      }
    ].to_json
  end

  def setup
    @old_conference = create(:conference, acronym: 'djangocon2018')
    @conference = create(:conference, acronym: 'gpn18')
    FileUtils.mkdir_p('tmp/tests')
    tempfile = 'tmp/tests/relive-toc.json'
    File.open(tempfile, 'w') do |f|
      f.puts relive_toc
    end
    ENV['RELIVE_URL'] = tempfile
  end

  def test_perform
    worker = ConferenceReliveDownloadWorker.new
    assert worker.perform
    @conference.reload
    assert_includes @conference.metadata.keys, 'relive'
    event = @conference.metadata['relive'].first
    assert_equal 'https://cdn.c3voc.de/relive/lac18/35/index.m3u8', event['playlist']
  end
end
