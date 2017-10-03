require 'active_support/concern'

module Storage
  extend ActiveSupport::Concern

  module ClassMethods
    def has_attached_directory(symbol, via: nil, url: nil, url_path: nil)
      AttachedDirectory.define_on(self, symbol, via, url, url_path)
    end

    def has_attached_file(symbol, via: nil, folder: nil, belongs_into: nil, on: nil)
      AttachedFile.define_on(
        self, symbol, belongs_into,
        OpenStruct.new(via: via, folder: folder, association_for_dir: on)
      )
    end
  end

  private

  class MethodName
    class << self
      def for_url(symbol)
        "get_#{symbol}_url".freeze
      end
      def for_url_path(symbol)
        "get_#{symbol}_url_path".freeze
      end
    end
  end

  class PathValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.nil? or value.blank?
      return if File.join('/test'.freeze, value) == File.absolute_path(value, '/test'.freeze)
      record.errors.add(attribute, 'not a valid path')
    end
  end

  class AttachedDirectory
    def self.define_on(klass, symbol, instance_var, url, url_path)
      klass.send :validates, instance_var, path: true

      klass.send :define_method, MethodName.for_url(symbol) do
        URL.join url, url_path, send(instance_var)
      end

      klass.send :define_method, MethodName.for_url_path(symbol) do
        '/'.freeze + URL.join(url_path, send(instance_var))
      end
    end
  end

  class AttachedFile
    def self.define_on(klass, symbol, dir_symbol, ivars)
      klass.send :validates, ivars.via, path: true

      define_storage_url_helper(
        klass,
        MethodName.for_url(symbol),
        MethodName.for_url(dir_symbol),
        ivars,
        ''
      )

      define_storage_url_helper(
        klass,
        MethodName.for_url_path(symbol),
        MethodName.for_url_path(dir_symbol),
        ivars,
        '/'
      )
    end

    def self.define_storage_url_helper(klass, helper_name, url_name, ivars, prefix)
      klass.send :define_method, helper_name do
        target = ivars.association_for_dir ? send(ivars.association_for_dir) : self
        folder = ivars.folder ? send(ivars.folder) : ''
        prefix + URL.join(target.send(url_name), folder, send(ivars.via))
      end
    end
  end

  class URL
    def self.join(*args)
      args.select(&:present?).map { |w|
        w = w.dup
        w.sub!(%r{^/}, ''.freeze)
        w.sub!(%r{/$}, ''.freeze)
        w
      }.join('/'.freeze).freeze
    end
  end
end
