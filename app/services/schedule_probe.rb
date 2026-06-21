# frozen_string_literal: true

require 'net/http'

# Probes candidate schedule endpoints derived from a base URL and returns
# availability + upstream system info for each format.
class ScheduleProbe
  TIMEOUT = 8

  def initialize(base_url)
    @base_url = base_url.to_s.strip
  end

  def probe
    xml_url  = variant('xml')
    json_url = variant('json')

    {
      current_url: @base_url,
      formats: [check_xml(xml_url), check_json(json_url)].compact
    }
  end

  private

  # Replace the schedule filename suffix, or append if no known file is present.
  def variant(suffix)
    if @base_url.match?(/schedule\.(xml|json)(\?|$)/)
      @base_url.sub(/schedule\.(xml|json)/, "schedule.#{suffix}")
    else
      "#{@base_url.chomp('/')}/schedule.#{suffix}"
    end
  end

  def check_xml(url)
    { id: 'xml', label: 'Schedule XML (Frab / Pentabarf)', url: url, available: head_ok?(url), upstream: nil }
  end

  def check_json(url)
    unless head_ok?(url)
      return { id: 'json', label: 'Schedule JSON (not found)', url: url, available: false, upstream: nil }
    end

    snippet   = partial_get(url)
    id, label, upstream = classify_json(snippet)
    { id: id, label: label, url: url, available: true, upstream: upstream }
  end

  def head_ok?(url, hops = 3)
    uri = URI.parse(url)
    res = Net::HTTP.start(uri.host, uri.port,
                          use_ssl: uri.scheme == 'https',
                          open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      http.head(uri.request_uri, 'User-Agent' => 'voctoweb/schedule-probe')
    end
    return head_ok?(res['location'], hops - 1) if res.is_a?(Net::HTTPRedirection) && hops > 0

    res.is_a?(Net::HTTPSuccess)
  rescue StandardError
    false
  end

  def partial_get(url, bytes: 2048)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      req = Net::HTTP::Get.new(uri.request_uri,
                               'Range'      => "bytes=0-#{bytes - 1}",
                               'User-Agent' => 'voctoweb/schedule-probe')
      res = http.request(req)
      res.body.to_s.force_encoding('UTF-8').scrub[0, bytes]
    end
  rescue StandardError
    ''
  end

  # Classify JSON format from the first ~2 KB of the body.
  # Schedule2 is identified by "schema2" in the $schema value.
  # Schedule1 carries a "generator" block near the top (pretalx or other).
  def classify_json(snippet)
    if snippet.match?(/"\$schema"\s*:[^,\n]*schema2/)
      name, version = extract_generator(snippet)
      upstream = [name, version].compact.reject(&:empty?).join(' ').presence || 'c3voc hub'
      ['json2', 'schedule2 JSON', upstream]
    else
      name, version = extract_generator(snippet)
      upstream = [name, version].compact.reject(&:empty?).join(' ').presence
      label    = name.present? ? "schedule1 JSON (#{name})" : 'schedule1 JSON'
      ['json1', label, upstream]
    end
  end

  def extract_generator(snippet)
    if (m = snippet.match(/"generator"\s*:\s*\{([^}]+)\}/m))
      block   = m[1]
      name    = block[/"name"\s*:\s*"([^"]+)"/, 1]
      version = block[/"version"\s*:\s*"([^"]+)"/, 1]
      [name, version]
    else
      [nil, nil]
    end
  end
end
