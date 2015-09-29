require 'test_helper'

module Frontend
  class FolderListTest < ActiveSupport::TestCase
    test "lists folders for given slug" do
      one = create :frontend_conference, slug: 'conf/one'
      two = create :frontend_conference, slug: 'conf/two'
      create :frontend_conference, slug: 'conf/more/three'
      create :frontend_conference, slug: 'conf/more/four'
      folders = FolderList.new('conf').folders
      assert_equal 3, folders.length
      assert_equal one, folders[0].conference
      assert_equal two, folders[1].conference
      assert_equal nil, folders[2].conference
      assert_equal 'conf/more', folders[2].location
    end

    test "lists folders for root" do
      one = create :frontend_conference, slug: 'one'
      two = create :frontend_conference, slug: 'conf/two'
      folders = FolderList.new('').folders
      assert_equal one, folders[0].conference
      assert_equal nil, folders[1].conference
      assert_equal 'conf', folders[1].location
    end
  end
end
