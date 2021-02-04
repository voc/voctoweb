require 'test_helper'
require 'json'

class ConferencesGraphQLApiTest < ActionDispatch::IntegrationTest

  test 'load conference by acronym/id' do
    query_string = <<-GRAPHQL
      query($id: ID!) {
        conference(id: $id){
          id
          title
          slug
          logoUrl
          aspectRatio
          scheduleUrl
          updatedAt
          eventLastReleasedAt
          lectures(first: 1) {
            nodes {
              title
            }
          }
        }
      }
    GRAPHQL

    # test for empty result
    result = MediaBackendSchema.execute(query_string, variables: { id: ''})
    assert_nil result['data']['conference']
    assert_nil result['errors']

    # test for example conference result
    create :conference, acronym: 'frabcon'
    result = MediaBackendSchema.execute(query_string, variables: { id: 'frabcon' })

    conference = result['data']['conference']
    assert_equal 'frabcon', conference['id']
    assert_nil result['errors']
  end


  test 'load newest conference' do
    query_string = <<-GRAPHQL
      query {
        conferences(first: 1) {
          id
          title
          slug
          logoUrl
          aspectRatio
          scheduleUrl
          updatedAt
          eventLastReleasedAt
          lectures(first: 1) {
            nodes {
              title
            }
          }
        }
      }
    GRAPHQL

    create(:conference_with_recordings)
    result = MediaBackendSchema.execute(query_string)
    assert_nil result['errors']
  end

  test 'load most recent conference' do
    query_string = <<-GRAPHQL
      query {
        conferencesRecent(first: 1) {
          id
          title
          slug
          logoUrl
          aspectRatio
          scheduleUrl
          updatedAt
          eventLastReleasedAt
          lectures(first: 1) {
            nodes {
              title
            }
          }
        }
      }
    GRAPHQL

    create(:conference_with_recordings)
    result = MediaBackendSchema.execute(query_string)
    assert_nil result['errors']
    assert result['data']['conferencesRecent'].length == 1
  end

end
