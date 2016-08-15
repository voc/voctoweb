class Languages
  LANGUAGES = {
    'eng' => ['en', 'English'],
    'deu' => ['de', 'German'],
    'gsw' => ['de-ch', 'Swiss German'],
    'fra' => ['fr', 'French'],
    'spa' => ['es', 'Spanish'],
    'jpn' => ['ja', 'Japanese']
  }.freeze

  class << self
    def all
      LANGUAGES.keys
    end

    def to_iso_639_1(lang)
      LANGUAGES[lang][0]
    end
    
    def to_string(lang)
      LANGUAGES[lang][1]
    end
  end
end
