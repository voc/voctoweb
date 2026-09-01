module Types
  class ImageMimeTypeEnum < Types::BaseEnum
    description "MIME type for images"
    value "SVG", "SVG format", value: "image/svg+xml"
    value "PNG", "PNG format", value: "image/png"
    value "JPEG", "JPEG format", value: "image/jpeg"
    value "WEBP", "WebP format", value: "image/webp"
  end
end
