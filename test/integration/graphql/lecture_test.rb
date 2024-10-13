require 'test_helper'
require 'json'

class LectureGraphQLApiTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create :conference_with_recordings
  end

  test 'load lecture by guid' do
    query_string = <<-GRAPHQL
      query($id: ID!) {
        lecture(guid: $id){
          title
          guid
          persons
          duration
          link
          images {
            thumbUrl
            posterUrl
          }
          timelens {
            timelineUrl
            thumbnailsUrl
          }
          videos {
            width
            mimeType
            language
            url
          }
          subtitles {
            language
            filename
          }
        }
      }
    GRAPHQL

    # test for empty result
    result = MediaBackendSchema.execute(query_string, variables: { id: ''})
    assert_nil result['data']['lecture']
    assert_nil result['errors']

    # test for example conference result
    create(:conference_with_recordings)
    result = MediaBackendSchema.execute(query_string, variables: { id: '12345' })
    assert_nil result['errors']
  end

  test 'load newest conference' do
    query_string = <<-GRAPHQL
      query($id: ID!) {
        lecturesRelatedTo(guid: $id) {
          nodes {
            title
            images {
              thumbUrl
              posterUrl
            }
          }
        }
      }
    GRAPHQL

    @event = create :event
    result = MediaBackendSchema.execute(query_string, variables: { id: @event.id })
    assert_nil result['errors']
  end

  unless ENV['SKIP_ELASTICSEARCH']
    test 'search for lectures' do
      query_string = <<-GRAPHQL
      query($query: String!) {
        lectureSearch(query: $query) {
          title
           images {
             thumbUrl
             posterUrl
          }
        }
      }
      GRAPHQL
      result = MediaBackendSchema.execute(query_string, variables: { query: "not-existing" })
      assert_empty result['data']['lectureSearch']
    end

    test 'search for lectures return multiple results' do
      Event.__elasticsearch__.create_index! force: true
      create_list(:event, 26, title: 'fake-event')
      Event.import
      Event.__elasticsearch__.refresh_index!

      query_string = <<-GRAPHQL
      query($query: String!) {
        lectureSearch(query: $query) {
          title
           images {
             thumbUrl
             posterUrl
          }
        }
      }
      GRAPHQL
      result = MediaBackendSchema.execute(query_string, variables: { query: "fake-event" })
      assert_nil result['errors']
      assert_equal 25, result['data']['lectureSearch'].count
      query_string = <<-GRAPHQL
      query($query: String!, $page: Int!) {
        lectureSearch(query: $query, page: $page) {
          title
           images {
             thumbUrl
             posterUrl
          }
        }
      }
      GRAPHQL
      result = MediaBackendSchema.execute(query_string, variables: { query: "fake-event", page: 2 })
      assert_nil result['errors']
      assert_equal 1, result['data']['lectureSearch'].count
    end
  end
end
