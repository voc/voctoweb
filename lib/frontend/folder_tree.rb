# frozen_string_literal: true
module Frontend
  class FolderNode
    def initialize(name = '', path = '')
      @childs = {}
      @name = name.freeze
      @path = build_path(path, name).freeze
    end
    attr_accessor :conference_id
    attr_reader :childs, :path, :name

    def add(name)
      if @childs.key? name
        fail 'rejected: trying to add on a conference nodes, but they are always terminal' if @childs[name].conference_id
        @childs[name]
      else
        @childs[name] = FolderNode.new(name, @path)
      end
    end

    def add_conference(name, id)
      node = add(name)
      node.conference_id = id
    end

    def conference?
      @conference_id.present?
    end

    def conference
      Conference.find(@conference_id)
    end

    def parent_path
      return '' if path == name
      pos = path.rindex(name) - 2
      path[0..pos]
    end

    private

    def build_path(path, name)
      [path, name].reject { |f| f == '' }.join('/')
    end
  end

  class FolderTree
    def initialize
      @root = FolderNode.new
    end

    def build(nodes = [])
      nodes.each { |id, path| add_path(id, path) }
    end

    def folders_at(path)
      parts = path.split('/')
      start = @root
      parts.each do |part|
        start = start.childs[part]
        return unless start
      end
      return unless start
      start.childs.values
    end

    def sort_folders(folders)
      sorted = folders.select { |folder| not folder.conference? }.sort { |a, b| a.name <=> b.name }
      sorted += (folders - sorted).sort { |a, b| b.name <=> a.name }
      sorted
    end

    private

    def add_path(id, path)
      parts = path.split('/')
      start = @root
      parts[0..-2].each { |part| start = start.add(part) }
      start.add_conference(parts[-1], id)
    end
  end
end
