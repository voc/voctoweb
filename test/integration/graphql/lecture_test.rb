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

end
