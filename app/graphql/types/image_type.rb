module Types
  class ImageType < Types::BaseObject
    description "An image e.g. logo or banner, with basic metadata"

    field :url, UrlType, "The URL of the image", null: false
    field :mime_type, String, "The MIME type of the image, e.g. `image/png` or `image/svg+xml`", null: false
    field :type, Types::ImageTypeEnum, "The purpose or type of the image", null: true
    field :variant, Types::ImageVariantEnum, "The variant of the image, e.g. `light` or `dark` for logos", null: true
  end
end
