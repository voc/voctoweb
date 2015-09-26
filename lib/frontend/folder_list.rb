module Frontend
  class FolderList
    def initialize(location='')
      @location = location
      @depth = parts(location).length
    end

    def folders
      @seen = {}
      @folders = []
      Conference.where('slug LIKE ?', "#{@slug}%").each do |conference|
        add_folder(conference)
      end
      @folders
    end

    private

    def parts(conference_slug)
      conference_slug.split('/')
    end

    def add_folder(conference)
      folder = Folder.new(location: conference.slug)
      folder.conference = conference if reachable?(conference)
      return if folder.conference.nil? && already_known?(folder.parent)
      @folders << folder
    end

    def already_known?(parent)
      return true if @seen[parent]
      @seen[parent] = 1
      false
    end

    def reachable?(conference)
      parts(conference.slug).length == @depth + 1
    end
  end
end
