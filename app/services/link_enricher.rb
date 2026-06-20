# frozen_string_literal: true

require 'webfinger'
require 'metainspector'

# Determines link_type and service for a Link URL.
#
# Two-phase detection:
#   1. enrich_from_pattern  — pure regex, no HTTP, called synchronously in before_validation
#   2. enrich_via_webfinger — uses the `webfinger` gem (Faraday-backed), queued as Sidekiq job
#
# Fediverse detection follows the same multi-stage approach as Podlove Publisher PR #1195:
# extract an acct: resource from the URL, resolve via WebFinger, inspect the returned
# ActivityPub self-link to distinguish Mastodon from PeerTube instances.
#
class LinkEnricher
  # [pattern, service, link_type]
  URL_PATTERNS = [
    [%r{\Ahttps?://(www\.)?github\.com/},              'GITHUB',     'WEB'],
    [%r{\Ahttps?://(www\.)?gitlab\.com/},              'GITLAB',     'WEB'],
    [%r{\Ahttps?://codeberg\.org/},                    'FORGEJO',    'WEB'],
    [%r{\Ahttps?://(www\.)?(bsky\.app|bsky\.social)/}, 'BLUESKY',    'WEB'],
    [%r{\Ahttps?://(www\.)?instagram\.com/},           'INSTAGRAM',  'WEB'],
    [%r{\Ahttps?://(www\.)?threads\.net/},             'THREADS',    'WEB'],
    [%r{\Ahttps?://(www\.)?(twitter\.com|x\.com)/},    'TWITTER',    'WEB'],
    [%r{\Ahttps?://media\.ccc\.de/},                   'MEDIACCCDE', 'MEDIA'],
  ].freeze

  ACTIVITYPUB_TYPES = [
    'application/activity+json',
    'application/ld+json; profile="https://www.w3.org/ns/activitystreams"',
  ].freeze

  Result = Struct.new(:link_type, :service, :name, keyword_init: true)

  # og:type prefix → link_type (video.other → "video" → MEDIA)
  OG_TYPE_MAP = {
    'video'   => 'MEDIA',    # video.movie, video.episode, video.tv_show, video.other
    'music'   => 'MEDIA',    # music.song, music.album, music.playlist, music.radio_station
    'article' => 'ARTICLE',
    'book'    => 'ARTICLE',
    'profile' => 'WEB',
  }.freeze

  # Phase 1: synchronous, no HTTP.
  def self.enrich_from_pattern(url)
    return Result.new if url.blank?

    URL_PATTERNS.each do |pattern, service, link_type|
      return Result.new(service: service, link_type: link_type) if url.match?(pattern)
    end

    Result.new
  end

  # Phase 2: WebFinger lookup via the `webfinger` gem.
  # Extracts an acct: resource from the URL path and resolves it.
  # Returns a Result or nil when the host does not support WebFinger or the
  # URL does not look like a Fediverse profile.
  def self.enrich_via_webfinger(url)
    return nil if url.blank?

    uri      = URI.parse(url)
    username = fediverse_username(uri)
    return nil unless username

    resource = "acct:#{username}@#{uri.host}"
    response = WebFinger.discover!(resource)

    ap_link = response.links&.find { |l| ACTIVITYPUB_TYPES.include?(l['type']) }
    return nil unless ap_link

    service = peertube_self_link?(ap_link) ? 'PEERTUBE' : 'MASTODON'
    Result.new(service: service, link_type: 'ACTIVITYPUB')
  rescue WebFinger::Exception, Faraday::Error, URI::InvalidURIError, JSON::ParserError
    nil
  end

  # Phase 3: OpenGraph fetch via metainspector.
  # Uses download_limit to abort after 256KB — covers <head> on virtually all pages,
  # equivalent to a range request without relying on server-side Range support.
  def self.enrich_from_opengraph(url)
    page = MetaInspector.new(url, download_limit: 262_144, timeout: 5, allow_redirections: :all)
    props     = page.meta_tags['property'] || {}
    og_type   = Array(props['og:type']).first
    link_type = OG_TYPE_MAP[og_type&.split('.', 2)&.first]
    name      = (Array(props['og:title']).first || page.title).presence
    Result.new(name: name, link_type: link_type)
  rescue MetaInspector::Error, Faraday::Error, Errno::ECONNREFUSED, URI::InvalidURIError
    Result.new
  end

  # ------------------------------------------------------------------ private

  # Mastodon-style:  /@alice   or  /users/alice
  # PeerTube-style:  /accounts/alice  or  /video-channels/mychannel
  def self.fediverse_username(uri)
    uri.path.match(%r{\A/(?:@|users/|accounts/|video-channels/)([^/]+)\z})&.[](1)
  end
  private_class_method :fediverse_username

  def self.peertube_self_link?(link)
    href = link['href'].to_s
    href.include?('/accounts/') || href.include?('/video-channels/')
  end
  private_class_method :peertube_self_link?
end
