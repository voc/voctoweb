module Types
  class ImageTypeEnum < Types::BaseEnum
    description "Type or purpose of the image"
    value "LOGO", "Logo image", value: "logo"
    value "BANNER", "Banner image", value: "banner"
    value "OTHER", "Other image type", value: "other"
    value "THUMBNAIL", "Thumbnail image", value: "thumbnail"
    value "POSTER", "Poster image", value: "poster"
  end

  class ImageVariantEnum < Types::BaseEnum
    description "Variant of the image"
    value "LIGHT", "Light mode image", value: "light"
    value "DARK", "Dark mode image", value: "dark"
  end
end
