require 'test_helper'

class ConferenceStreamingDownloadWorkerTest < ActiveSupport::TestCase
  def setup
    create(:conference, acronym: '32c3')
  end

  def test_perform
    worker = ConferenceStreamingDownloadWorker.new
    assert worker.perform
  end
end
