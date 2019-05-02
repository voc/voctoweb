module Types
  class AssetType < Types::BaseObject
    field :filename, String, null: false
    field :url, String, null: false
    field :mime_type, String, null: false
    field :language, String, null: true

    def url
      object.get_recording_url
    end
  end
end
