json.mirrors(@mirrors.select { |m| m.enabled }.sort { |a,b| a.identifier <=> b.identifier }) do |mirror|
  json.code :success
  json.identifier mirror.identifier
  json.baseurl mirror.baseurl unless mirror.baseurl.match /@/
  json.status_baseurl mirror.status_baseurl
  json.region mirror.region
  json.country mirror.country
  json.lat mirror.lat
  json.lng mirror.lng
  json.asn mirror.asn
  json.last_scan l(mirror.last_scan, format: :pretty_datetime)
end
