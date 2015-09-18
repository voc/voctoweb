class Settings
  def self.method_missing(name)
    fail "not implemented: #{name}" unless config.respond_to?(name)
    config.public_send(name)
  end

  def self.respond_to?(name)
    config.respond_to?(name)
  end

  def self.config
    @config ||= OpenStruct.new JSON.load(open(Rails.root.join('config/settings.json')))
  end
end
