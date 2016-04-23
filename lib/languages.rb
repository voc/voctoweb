class Languages
  LANGUAGES = {
    "deu" => "de",
    "eng" => "en",
    "fra" => "fr",
    "gsw" => "de-ch"
  }
  
  class << self
    def all
      LANGUAGES.keys()
    end
    
    def to_iso_639_1(lang)
      return LANGUAGES[lang]
    end
  end
end