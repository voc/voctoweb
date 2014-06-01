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

  class AttachedDirectory

    def self.define_on(klass, symbol, instance_var, prefix, url, url_path)

      klass.send :define_method, "get_#{symbol}_url" do
        URL.join url, url_path, self.send(instance_var)
      end

      klass.send :define_method, "get_#{symbol}_url_path" do
        '/' + URL.join(url_path, self.send(instance_var))
      end

      klass.send :define_method, "get_#{symbol}_path" do
        Storage.file_join prefix, self.send(instance_var)
      end
    end
  end

  class AttachedFile

    def self.define_on(klass, symbol, via, ivar_folder, dir_symbol, on)

      klass.send :define_method, "get_#{symbol}_url" do
        target = on ? self.send(on) : self
        folder = ivar_folder ? self.send(ivar_folder) : ''
        URL.join target.send("get_#{dir_symbol}_url"), folder, self.send(via)
      end

      klass.send :define_method, "get_#{symbol}_url_path" do
        target = on ? self.send(on) : self
        folder = ivar_folder ? self.send(ivar_folder) : ''
        '/' + URL.join(target.send("get_#{dir_symbol}_url_path"), folder, self.send(via))
      end

      klass.send :define_method, "get_#{symbol}_path" do
        target = on ? self.send(on) : self
        parts = []
        parts << target.send("get_#{dir_symbol}_path")
        parts << self.send(ivar_folder) if ivar_folder
        parts << self.send(via)
        Storage.file_join parts
      end

      klass.send :define_method, "get_#{symbol}_dir" do
        target = on ? self.send(on) : self
        return if target.nil?
        folder = ivar_folder ? self.send(ivar_folder) : ''
        Storage.file_join target.send("get_#{dir_symbol}_path"), folder
      end
    end
  end

  def self.file_join(*args)
    File.join args.flatten.select { |w| w.present? }
  end

  class URL
    def self.join(*args)
      args.select { |w| w.present? }.map { |w| w.sub(%r'^/', '').sub(%r'/$', '') }.join('/')
    end
  end
end
