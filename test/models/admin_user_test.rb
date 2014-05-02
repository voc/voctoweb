require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  test "should create admin user" do
    r = create :admin_user
    assert r.valid?
   end
end
