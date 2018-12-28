class Languages
  LANGUAGES = {
    'eng' => ['en', 'English'],
    'deu' => ['de', 'German'],
    'gsw' => ['de-ch', 'Swiss German'],
    'fra' => ['fr', 'French'],
    'spa' => ['es', 'Spanish'],
    'jpn' => ['ja', 'Japanese'],
    'rus' => ['ru', 'Russian'],
    'chi' => ['zh', 'Chinese'],
    'ara' => ['ar', 'Arabic'],
    'orig' => ['', 'Original (different presenters using not the same languages, text not translated)'] # use only for subtiltes and not for audio or video recordings!
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
