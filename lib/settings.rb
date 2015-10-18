class Settings
  def self.method_missing(name)
    fail "not implemented: #{name}" unless config.respond_to?(name)
    # FIXME mock this instead
    if name == :folders && Rails.env.test?
      {
        'recordings_base_dir' => Rails.root.join('tmp', 'tests', 'rec'),
        'images_base_dir' => Rails.root.join('tmp', 'tests', 'img'),
        'recordings_webroot' => '',
        'images_webroot' => '',
        'tmp_dir' => '/tmp'
      }
    else
      config.public_send(name)
    end
  end

  def self.respond_to?(name)
    config.respond_to?(name)
  end

  def self.config
    @config ||= OpenStruct.new YAML.load(open(Rails.root.join('config/settings.yml')))
  end
end
