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
      assert_nil folders[0].conference_id

      paths = folders.map{ |folder| folder.path }
      assert_includes paths, 'a'
      assert_includes paths, 'h'


      folders = tree.folders_at('a')
      assert_equal 3, folders.length

      paths = folders.map{ |folder| folder.path }
      assert_includes paths, 'a/b'
      assert_includes paths, 'a/e'
      assert_includes paths, 'a/g'


      folders = tree.folders_at('a/b')
      assert_equal 2, folders.length

      paths = folders.map{ |folder| folder.path }
      assert_includes paths, one.slug
      assert_includes paths, two.slug

      conference_ids = folders.map{ |folder| folder.conference_id }
      assert_includes conference_ids, one.id
      assert_includes conference_ids, two.id
    end

    test 'fails to create invalid folder' do
      one = create :frontend_conference, slug: 'a/b/c'
      two = build :frontend_conference, slug: 'a/b'

      assert one.valid?
      refute two.valid?
    end
  end
end
