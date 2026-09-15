# frozen_string_literal: true

class LinkEnrichWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(link_id)
    link = Link.find_by(id: link_id)
    return unless link

    result = LinkEnricher.enrich_via_webfinger(link.url)
    return unless result

    updates = {}
    updates[:link_type] = result.link_type if result.link_type.present? && link.link_type.blank?
    updates[:service]   = result.service   if result.service.present?   && link.service.blank?

    link.update_columns(updates) if updates.any?
  end
end
