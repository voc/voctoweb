require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase
  test "should set initial state" do
    c = Conference.new
    assert c.not_present?
   end

  test "should not save conference without acronym" do
    c = Conference.new
    assert_raises (ActiveRecord::RecordInvalid) { c.save!  }
  end
end
