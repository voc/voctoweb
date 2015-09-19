class MirrorFile < MirrorBrain
  self.table_name = :filearr

  def self.torrent_hashes
    return [] if Rails.env.test? # skip, because there are no postgresql functions in test database
    Mirror.connection.execute(%{SELECT f.path, h.btihhex FROM hexhash h JOIN filearr f ON f.id = h.file_id}).to_a
  end

end

