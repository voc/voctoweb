require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  test "should create news" do
    assert_difference('News.count') do
      create :news
    end
  end
  test "should not save without date" do
    r = News.new
    r.title = 'a'
    r.body = 'b'
    assert_raises(ActiveRecord::RecordInvalid) { r.save!  }
  end
end
