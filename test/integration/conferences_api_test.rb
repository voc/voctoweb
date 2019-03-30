require 'test_helper'

class ConferencesApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @json = json_text
  end

  def json_text
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"conference":'
    url = 'file://' + File.join(Rails.root, 'test', 'fixtures', 'schedule.xml')
    d = %'{"acronym":"frab666","recordings_path":"conference/frab123","images_path":"events/frab","slug":"event/frab/frab123","aspect_ratio":"16:9","title":null,"schedule_url":"#{url}"}'
    json += d
    json+= '}'
    json
  end

  test "should create conference" do
    FileUtils.mkdir_p 'tmp/tests/rec/conference/frab123'
    FileUtils.mkdir_p 'tmp/tests/img/events/frab'
    assert JSON.parse(@json)
    run_background_jobs_immediately do
      assert_difference('Conference.count') do
        post_json '/api/conferences.json', @json
      end
    end
  end

end

