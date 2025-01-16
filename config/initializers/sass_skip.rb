require "sprockets/sass_compressor"

# https://stackoverflow.com/a/77544219
module SkipSassCompression
  SEARCH = "graphiql-react".freeze

  def call(input)
    if skip_compression?(input[:data])
      input[:data]
    else
      super
    end
  end

  def skip_compression?(body)
    body.include?(SEARCH)
  end
end

Sprockets::SassCompressor.prepend SkipSassCompression
