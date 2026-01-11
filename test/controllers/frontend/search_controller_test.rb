require 'test_helper'

class Frontend::SearchControllerTest < ActionController::TestCase
  setup do
    Event.__elasticsearch__.create_index! force: true
    create_list(:conference_with_recordings, 5)
  end

  unless ENV['SKIP_ELASTICSEARCH']
    test 'should get index' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { q: 'FrabCon' }
      assert_response :success
      assert_equal 25, assigns(:events).count
    end

    test 'should sort correctly in asc order' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { q: 'FrabCon', sort: 'asc' }
      assert_response :success
      
      assigns(:events).map(&:date).each_cons(2) do |a, b|
        assert a <= b, "Dates are not in ascending order: #{a} should be before #{b}"
      end
    end

    test 'should sort correctly in desc order' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { q: 'FrabCon', sort: 'desc' }
      assert_response :success
      
      assigns(:events).map(&:date).each_cons(2) do |a, b|
        assert a >= b, "Dates are not in descending order: #{a} should be before #{b}"
      end
    end

    test 'wrong sort param should not do anything bad' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { q: 'FrabCon', sort: 'descasc' }
      assert_response :success
      assert_equal 25, assigns(:events).count

      get :index, params: { p: 'Alice', sort: 'descasc' }
      assert_response :success
      assert_equal 10, assigns(:events).count
    end

    test 'querying for specific person should only return events for the person' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { p: 'Alice' }
      assert_response :success
      
      assigns(:events).each do |event|
        assert_includes event.structured_persons, 'Alice', "Expected 'Alice' to be in the persons array for event #{event.title}"
      end
    end

    test 'querying for specific person in ascending sort order should work' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { p: 'Alice', sort: 'asc' }
      assert_response :success
      events = assigns(:events)
      events.each do |event|
        assert_includes event.structured_persons, 'Alice', "Expected 'Alice' to be in the persons array for event #{event.title}"
      end
      events.map(&:date).each_cons(2) do |a, b|
        assert a <= b, "Dates are not in ascending order: #{a} should be before #{b}"
      end
    end

    test 'querying for specific person in descending sort order should work' do
      Event.import
      Event.__elasticsearch__.refresh_index!
      get :index, params: { p: 'Alice', sort: 'desc' }
      assert_response :success
      events = assigns(:events)
      events.each do |event|
        assert_includes event.structured_persons, 'Alice', "Expected 'Alice' to be in the persons array for event #{event.title}"
      end
      events.map(&:date).each_cons(2) do |a, b|
        assert a >= b, "Dates are not in ascending order: #{a} should be before #{b}"
      end
    end
  end
end
