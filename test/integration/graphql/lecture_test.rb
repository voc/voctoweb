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

  test 'recording size defaults to megabytes and can be requested in other units' do
    event = create(:event)
    create(:recording, event: event, mime_type: 'video/webm', size: 1_073_741_824) # 1 GiB

    query_string = <<-GRAPHQL
      query($id: ID!) {
        lecture(guid: $id) {
          videos {
            sizeDefault: size
            sizeMb: size(unit: MB)
            sizeGb: size(unit: GB)
            sizeByte: size(unit: BYTE)
          }
        }
      }
    GRAPHQL

    result = MediaBackendSchema.execute(query_string, variables: { id: event.guid })
    assert_nil result['errors']

    video = result['data']['lecture']['videos'].first
    assert_equal 1024, video['sizeDefault']
    assert_equal 1024, video['sizeMb']
    assert_equal 1, video['sizeGb']
    assert_equal 1_073_741_824, video['sizeByte']
  end

  test 'filter lectures by tag' do
    create(:event, tags: ['ruby', 'rails'])
    create(:event, tags: ['python'])

    query_string = <<-GRAPHQL
      query($tags: [String!]) {
        lectures(filter: { tagsContains: $tags }) {
          title
          tags
        }
      }
    GRAPHQL

    result = MediaBackendSchema.execute(query_string, variables: { tags: ['ruby'] })
    assert_nil result['errors']
    assert_equal 1, result['data']['lectures'].count
    assert_includes result['data']['lectures'].first['tags'], 'ruby'

    result = MediaBackendSchema.execute(query_string, variables: { tags: ['python'] })
    assert_equal 1, result['data']['lectures'].count

    result = MediaBackendSchema.execute(query_string, variables: { tags: ['nonexistent'] })
    assert_empty result['data']['lectures']
  end

  test 'sort lectures by view count' do
    popular = create(:event, tags: ['view-count-sort-test'], view_count: 1000)
    unpopular = create(:event, tags: ['view-count-sort-test'], view_count: 1)

    query_string = <<-GRAPHQL
      query($tags: [String!]) {
        lectures(filter: { tagsContains: $tags }, orderBy: viewCount_DESC) {
          guid
        }
      }
    GRAPHQL

    result = MediaBackendSchema.execute(query_string, variables: { tags: ['view-count-sort-test'] })
    assert_nil result['errors']
    assert_equal [popular.guid, unpopular.guid], result['data']['lectures'].map { |l| l['guid'] }
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
