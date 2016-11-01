require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  setup do
    @conference = create :conference_with_recordings
  end

  test 'should get index' do
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
  end

  test 'should get oembed' do
    get :oembed, params: { url: event_url(slug: @conference.events.first.slug) }
    assert_response :success
    oembed = JSON.parse(response.body)
    refute_empty oembed
    assert_equal 640, oembed['width']
    assert oembed['html'].include? '640'
  end

  test 'should get oembed with dimensions' do
    get :oembed, params: { url: event_url(slug: @conference.events.first.slug), maxwidth: 234 }
    assert_response :success
    oembed = JSON.parse(response.body)
    assert_equal 234, oembed['width']
    assert oembed['html'].include? '234'
  end
end
