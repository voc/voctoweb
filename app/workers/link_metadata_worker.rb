# frozen_string_literal: true

class LinkMetadataWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(link_id)
    link = Link.find_by(id: link_id)
    return unless link

    result = LinkEnricher.enrich_from_opengraph(link.url)

    updates = {}
    updates[:name]      = result.name      if result.name.present?      && link.name.blank?
    updates[:link_type] = result.link_type if result.link_type.present? && link.link_type.blank?

    link.update_columns(updates) if updates.any?
  end
end
