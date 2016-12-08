require 'test_helper'

module Frontend
  class RecentControllerTest < ActionController::TestCase
    test 'should redirect if slug is not found' do
      create :conference_with_recordings
      conference = create :conference_with_recordings
      conference.events.update_all(release_date: '2014-08-21')

      get :index
      assert_response :success
    end
  end
end
