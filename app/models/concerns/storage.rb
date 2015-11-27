require 'active_support/concern'

module Storage
  extend ActiveSupport::Concern

  module ClassMethods
    def has_attached_directory(symbol, via: nil, prefix: nil, url: nil, url_path: nil)
      AttachedDirectory.define_on(self, symbol, via, prefix, url, url_path)
    end

    def has_attached_file(symbol, via:nil, folder: nil, belongs_into: nil, on: nil)
      AttachedFile.define_on(self, symbol, via, folder, belongs_into, on)
    end
  end

  private

  module NameHelper
    def for_url(symbol)
      "get_#{symbol}_url".freeze
    end
    def for_url_path(symbol)
      "get_#{symbol}_url_path".freeze
    end
    def for_path(symbol)
      "get_#{symbol}_path".freeze
    end
    def for_dir(symbol)
      "get_#{symbol}_dir".freeze
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
    extend NameHelper
    def self.define_on(klass, symbol, instance_var, prefix, url, url_path)
      klass.send :validates, instance_var, path: true

      klass.send :define_method, for_url(symbol) do
        URL.join url, url_path, send(instance_var)
      end

      klass.send :define_method, for_url_path(symbol) do
        '/' + URL.join(url_path, send(instance_var))
      end

      klass.send :define_method, for_path(symbol) do
        Storage.file_join prefix, send(instance_var)
      end
    end
  end

  class AttachedFile
    extend NameHelper
    def self.define_on(klass, symbol, ivar_via, ivar_folder, dir_symbol, on)
      klass.send :validates, ivar_via, path: true

      url_name = for_url(dir_symbol)
      klass.send :define_method, for_url(symbol) do
        target = on ? send(on) : self
        folder = ivar_folder ? send(ivar_folder) : ''
        URL.join target.send(url_name), folder, send(ivar_via)
      end

      url_path_name = for_url_path(dir_symbol)
      klass.send :define_method, for_url_path(symbol) do
        target = on ? send(on) : self
        folder = ivar_folder ? send(ivar_folder) : ''
        '/' + URL.join(target.send(url_path_name), folder, send(ivar_via))
      end

      path_name = for_path(dir_symbol)
      klass.send :define_method, for_path(symbol) do
        target = on ? send(on) : self
        parts = []
        parts << target.send(path_name)
        parts << send(ivar_folder) if ivar_folder
        parts << send(ivar_via)
        Storage.file_join parts
      end

      klass.send :define_method, for_dir(symbol) do
        target = on ? send(on) : self
        return if target.nil?
        folder = ivar_folder ? send(ivar_folder) : ''
        Storage.file_join target.send(path_name), folder
      end
    end
  end

  def self.file_join(*args)
    File.join args.flatten.select(&:present?)
  end

  class URL
    def self.join(*args)
      args.select(&:present?).map { |w|
        w.sub!(%r{^/}, ''.freeze)
        w.sub!(%r{/$}, ''.freeze)
        w
      }.join('/'.freeze)
    end
  end
end
