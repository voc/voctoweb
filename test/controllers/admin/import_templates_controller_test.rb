require 'test_helper'

class Admin::ImportTemplatesControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list templates" do
    create :import_template
    get 'index'
    assert_response :success
  end

  test "should show new import template form" do
    get 'new'
    assert_response :success
  end

  test "should show an import template" do
    template = create :import_template
    get 'show', id: template.id
    assert_response :success
  end

end
