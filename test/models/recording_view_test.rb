require 'test_helper'

class RecordingViewTest < ActiveSupport::TestCase
  setup do
    @r1 = create(:recording)
    @r2 = create(:recording)
    @r3 = create(:recording)
    @r4 = create(:recording)
    @r5 = create(:recording)
    @r1a = create(:recording, event: @r1.event)
    @r3a = create(:recording, event: @r3.event)
    @r1.event.update(metadata: {'related' => {123 => 2}})
  end

  test 'should not save without event' do
    create(:recording_view, recording: @r1)
    create(:recording_view, recording: @r1)
    create(:recording_view, recording: @r2)
    create(:recording_view, recording: @r3)
    create(:recording_view, recording: @r4)
    create(:recording_view, recording: @r5)
    create(:recording_view, recording: @r1a)

    create(:recording_view, recording: @r1, user_agent: 'other/1.0')
    create(:recording_view, recording: @r2, user_agent: 'other/1.0')
    create(:recording_view, recording: @r3, user_agent: 'other/1.0')
    create(:recording_view, recording: @r4, user_agent: 'other/1.0')

    create(:recording_view, recording: @r1, user_agent: 'free/2.0')
    create(:recording_view, recording: @r2, user_agent: 'free/2.0')
    create(:recording_view, recording: @r3a, user_agent: 'free/2.0')

    UpdateRelatedEvents.new.update

    event = @r1.reload.event
    metadata = {'related' => {
      '123' => 2,
      @r2.event.id.to_s => 3,
      @r3.event_id.to_s => 3
    }}
    assert_equal metadata, event.metadata

    event = @r2.reload.event
    metadata = {'related' => {
      @r1.event_id.to_s => 3,
      @r3.event_id.to_s => 3
    }}
    assert_equal metadata, event.metadata

    event = @r4.reload.event
    metadata = {'related' => {
      @r1.event_id.to_s => 2,
      @r2.event_id.to_s => 2,
      @r3.event_id.to_s => 2
    }}
    assert_equal metadata, event.metadata
  end
end
