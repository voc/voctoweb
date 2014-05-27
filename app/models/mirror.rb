class MirrorBrain < ActiveRecord::Base
    self.abstract_class = true
    self.establish_connection 'mirrorbrain'
end

class Mirror < MirrorBrain
  self.table_name = 'server'

  def to_json
    Jbuilder.encode do |json|
      json.extract! self, :identifier, :baseurl, :baseurl_ftp, :enabled, :status_baseurl, :region, :country, :asn, :lat, :lng, :prefix, :last_scan
      json.baseurl_rsync baseurl_rsync unless baseurl_rsync.include? '@'
    end
  end

end
