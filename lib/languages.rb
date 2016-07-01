class Languages
  LANGUAGES = {
    'deu' => 'de',
    'spa' => 'es',
    'eng' => 'en',
    'fra' => 'fr',
    'gsw' => 'de-ch'
  }.freeze

  class << self
    def all
      LANGUAGES.keys
    end

    def to_iso_639_1(lang)
      LANGUAGES[lang]
    end
  end
end
