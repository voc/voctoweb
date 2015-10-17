require 'test_helper'

module Frontend
  class FolderTreeTest < ActiveSupport::TestCase
    test 'builds tree' do
      one = create :frontend_conference, slug: 'a/b/c'
      two = create :frontend_conference, slug: 'a/b/d'
      create :frontend_conference, slug: 'a/e/f'
      create :frontend_conference, slug: 'a/g'
      create :frontend_conference, slug: 'h/i'

      tree = FolderTree.new
      tree.build(Conference.pluck(:id, :slug))

      folders = tree.folders_at('')
      assert_equal 2, folders.length
      assert_equal nil, folders[0].conference_id
      assert_equal 'a', folders[0].path

      folders = tree.folders_at('a')
      assert_equal 3, folders.length
      assert_equal 'a/b', folders[0].path

      folders = tree.folders_at('a/b')
      assert_equal 2, folders.length
      assert_equal one.id, folders[0].conference_id
      assert_equal one.slug, folders[0].path
      assert_equal two.id, folders[1].conference_id
    end

    test 'fails to create invalid folder' do
      one = create :frontend_conference, slug: 'a/b/c'
      two = build :frontend_conference, slug: 'a/b'

      assert one.valid?
      refute two.valid?
    end
  end
end
