require "sprockets/sass_compressor"

# https://stackoverflow.com/a/77544219
module SkipSassCompression
  # Prebuilt, already-minified vendor blobs whose modern CSS libsass can't
  # parse; "vds-" is the class prefix of the vendored vidstack-player.css.
  SEARCH = ["graphiql-react", "vds-"].freeze

  def call(input)
    if skip_compression?(input[:data])
      input[:data]
    else
      super
    end
  end

  def skip_compression?(body)
    SEARCH.any? { |marker| body.include?(marker) }
  end
end

Sprockets::SassCompressor.prepend SkipSassCompression
