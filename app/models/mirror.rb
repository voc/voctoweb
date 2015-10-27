class Mirror < MirrorBrain
  self.table_name = :server

  def nfiles
    return [] if Rails.env.test? # skip, because there are no postgresql functions in test database
    Mirror.connection.execute(%{SELECT mirr_get_nfiles('#{self.identifier}')}).first['mirr_get_nfiles']
  end

  def to_json
    Jbuilder.encode do |json|
      json.extract! self, :identifier, :baseurl, :baseurl_ftp, :enabled, :status_baseurl, :region, :country, :asn, :lat, :lng, :prefix, :last_scan, :nfiles, :operator_url
      json.baseurl_rsync baseurl_rsync unless baseurl_rsync.include? '@'
    end
  end

end
