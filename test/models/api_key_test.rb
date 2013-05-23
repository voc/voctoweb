require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  test "should create key" do
    k = ApiKey.new description: "key1"
    k.save!
    assert_not_nil k.key
   end
end
