# frozen_string_literal: true

# Generic polymorphic link, attachable to any model via `has_many :links, as: :linkable`.
# Link type subsets mirror the hub model (core/models/links.py) and the schedule2 Reference schema.
class Link < ApplicationRecord
  PERSON_LINK_TYPES = %w[WEB BLOG ACTIVITYPUB RELATED ORIGIN].freeze
  EVENT_LINK_TYPES  = %w[SLIDES PAPER WEB BLOG ARTICLE BOOK MEDIA RELATED FEEDBACK ORIGIN ACTIVITYPUB].freeze
  ALL_TYPES         = (PERSON_LINK_TYPES + EVENT_LINK_TYPES).uniq.freeze

  SERVICES = %w[MASTODON BLUESKY INSTAGRAM THREADS TWITTER FORGEJO GITHUB GITLAB MEDIACCCDE PEERTUBE].freeze

  belongs_to :linkable, polymorphic: true

  validates :url,       presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }
  validates :link_type, inclusion: { in: ALL_TYPES,  allow_blank: true }
  validates :service,   inclusion: { in: SERVICES,   allow_blank: true }

  validate :link_type_allowed_for_linkable

  # Phase 1 (sync): fill blanks from URL patterns before validation.
  before_validation :enrich_from_pattern, if: -> { url.present? && (link_type.blank? || service.blank?) }

  # Phase 2 (async): WebFinger lookup — Fediverse profile URLs only.
  after_commit :enqueue_webfinger_enrichment,
               on: %i[create update],
               if: -> { service.blank? && url.present? }

  # Phase 3 (async): OpenGraph fetch — fills name and refines link_type for any URL.
  after_commit :enqueue_metadata_enrichment,
               on: %i[create update],
               if: -> { name.blank? && url.present? }

  private

  def enrich_from_pattern
    result = LinkEnricher.enrich_from_pattern(url)
    self.link_type = result.link_type if link_type.blank? && result.link_type.present?
    self.service   = result.service   if service.blank?   && result.service.present?
  end

  def enqueue_webfinger_enrichment
    LinkEnrichWorker.perform_async(id)
  end

  def enqueue_metadata_enrichment
    LinkMetadataWorker.perform_async(id)
  end

  def link_type_allowed_for_linkable
    return if link_type.blank?

    allowed = case linkable_type
              when 'Person'     then PERSON_LINK_TYPES
              when 'Event'      then EVENT_LINK_TYPES
              else ALL_TYPES
              end

    errors.add(:link_type, "is not allowed for #{linkable_type}") unless allowed.include?(link_type)
  end
end
