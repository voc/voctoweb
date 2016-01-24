require 'test_helper'

class StorageTest < ActiveSupport::TestCase
  setup do
    class BaseModel
      def self.validates(*_args)
      end
      extend Storage::ClassMethods
      attr_accessor :dir1, :file1
    end
  end

  test 'should add directory annotation' do
    class SomeModel < BaseModel
      has_attached_directory :dir,
        via: :dir1,
        url: 'http://example.com',
        url_path: 'web'
    end

    test = SomeModel.new
    test.dir1 = 'basedir1'

    assert_equal 'http://example.com/web/basedir1', test.get_dir_url
    assert_equal '/web/basedir1', test.get_dir_url_path
  end

  test 'should add file annotation' do
    class SomeModel < BaseModel
      has_attached_directory :dir,
        via: :dir1,
        url: 'http://example.com',
        url_path: 'web'
      has_attached_file :file, via: :file1, belongs_into: :dir
    end

    test = SomeModel.new
    test.dir1 = 'basedir1'
    test.file1 = 'testfile'

    assert_equal 'http://example.com/web/basedir1/testfile', test.get_file_url
    assert_equal '/web/basedir1/testfile', test.get_file_url_path
  end

  test 'should handle nil values in annotations' do
    class SomeModel < BaseModel
      has_attached_directory :dir,
        via: :dir1,
        url: 'http://example.com',
        url_path: 'web'
      has_attached_file :file, via: :file1, belongs_into: :dir
    end

    test = SomeModel.new

    assert_equal 'http://example.com/web', test.get_dir_url
    assert_equal '/web', test.get_dir_url_path
    assert_equal 'http://example.com/web', test.get_file_url
    assert_equal '/web', test.get_file_url_path
  end

  test 'should find file in other class directory' do
    class DirModel < BaseModel
      has_attached_directory :dir,
        via: :dir1,
        url: 'http://example.com',
        url_path: 'web'
    end

    class FileModel < BaseModel
      attr_accessor :parent
      has_attached_file :file, via: :file1, belongs_into: :dir, on: :parent
    end

    dir = DirModel.new
    dir.dir1 = 'basedir1'

    file = FileModel.new
    file.parent = dir
    file.file1 = 'testfile'

    assert_equal 'http://example.com/web/basedir1/testfile', file.get_file_url
    assert_equal '/web/basedir1/testfile', file.get_file_url_path
  end

  test 'should find file in subfolder' do
    class DirModel < BaseModel
      has_attached_directory :dir,
        via: :dir1,
        url: 'http://example.com',
        url_path: 'web'
    end

    class FileModel < BaseModel
      attr_accessor :parent, :folder
      has_attached_file :file, via: :file1, folder: :folder, belongs_into: :dir, on: :parent
    end

    dir = DirModel.new
    dir.dir1 = 'basedir1'

    file = FileModel.new
    file.folder = 'mp3'
    file.parent = dir
    file.file1 = 'testfile'

    assert_equal 'http://example.com/web/basedir1/mp3/testfile', file.get_file_url
    assert_equal '/web/basedir1/mp3/testfile', file.get_file_url_path
  end
end
