module PublicJsonHelper
  def json_cached_key(identifier, *models)
    'js_' + identifier.to_s + Digest::SHA1.hexdigest(models.flatten.map { |m| m.updated_at.to_i }.join(';'))
  end
end
