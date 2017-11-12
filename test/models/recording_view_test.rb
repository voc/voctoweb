require 'test_helper'

class RecordingViewTest < ActiveSupport::TestCase
  setup do
    @r1 = create(:recording)
    @r2 = create(:recording)
    @r1.event.update(metadata: {'related' => [123]})
  end

  test 'should not save without event' do
    create_list(:recording_view, 8, recording: @r2)
    create_list(:recording_view, 4, recording: @r1)
    create_list(:recording_view, 2, recording: @r1, user_agent: 'free/2.0')

    UpdateRelatedEvents.new.update

    @r1.reload
    @r2.reload

    metadata = { "related"=>[@r1.event.id] }
    assert_equal metadata, @r2.event.metadata
    metadata = { "related"=>[123,@r2.event.id] }
    assert_equal metadata, @r1.event.metadata
  end
end
