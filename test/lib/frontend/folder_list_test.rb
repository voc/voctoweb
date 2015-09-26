require 'test_helper'

module Frontend
  class FolderListTest < ActiveSupport::TestCase
    test "lists folders for given slug" do
      one = create :conference, slug: 'conf/one'
      two = create :conference, slug: 'conf/two'
      create :conference, slug: 'conf/more/three'
      create :conference, slug: 'conf/more/four'
      folders = FolderList.new('conf').folders
      assert_equal 3, folders.length
      assert_equal one, folders[0].conference
      assert_equal two, folders[1].conference
      assert_equal nil, folders[2].conference
      assert_equal 'conf/more/three', folders[2].location
    end

    test "lists folders for root" do
      one = create :conference, slug: 'one'
      two = create :conference, slug: 'conf/two'
      folders = FolderList.new('').folders
      assert_equal one, folders[0].conference
      assert_equal nil, folders[1].conference
      assert_equal 'conf/two', folders[1].location
    end
  end
end
