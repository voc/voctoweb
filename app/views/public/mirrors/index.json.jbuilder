json.array!(@mirrors.select { |m| m.enabled }) do |mirror|
  json.identifier mirror.identifier
  json.baseurl mirror.baseurl
  json.status_baseurl mirror.status_baseurl
  json.region mirror.region
  json.country mirror.country
  json.asn mirror.asn
  json.last_scan l(mirror.last_scan, format: :pretty_datetime)
end
