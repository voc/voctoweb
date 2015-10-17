module Frontend
  class FolderNode
    def initialize(name = '', path = '')
      @childs = {}
      @name = name
      @path = build_path(path, name)
    end
    attr_accessor :conference_id, :childs, :path, :name

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
      parts.each { |part| start = start.childs[part] }
      start.childs.values
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
