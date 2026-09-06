# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_06_221544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.integer "author_id"
    t.string "author_type", limit: 255
    t.text "body"
    t.datetime "created_at", precision: nil
    t.string "namespace", limit: 255
    t.string "resource_id", limit: 255, null: false
    t.string "resource_type", limit: 255, null: false
    t.datetime "updated_at", precision: nil
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip", limit: 255
    t.string "provider"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token", limit: 255
    t.integer "sign_in_count", default: 0
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_admin_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "description", limit: 255
    t.string "key", limit: 255
    t.datetime "updated_at", precision: nil
  end

  create_table "conferences", force: :cascade do |t|
    t.string "acronym", limit: 255
    t.string "aspect_ratio", limit: 255
    t.datetime "created_at", precision: nil
    t.text "custom_css"
    t.text "description"
    t.integer "downloaded_events_count", default: 0, null: false
    t.datetime "ends_at"
    t.datetime "event_last_released_at", precision: nil
    t.string "global_event_notes"
    t.string "images_path", limit: 255
    t.string "languages", default: [], array: true
    t.string "link", limit: 255
    t.string "logo", limit: 255
    t.jsonb "metadata", default: {}
    t.bigint "parent_id"
    t.string "recordings_path", limit: 255
    t.string "schedule_state", limit: 255, default: "not_present", null: false
    t.string "schedule_url", limit: 255
    t.text "schedule_xml"
    t.string "slug", limit: 255, default: ""
    t.datetime "starts_at"
    t.jsonb "streaming", default: {}
    t.string "title", limit: 255
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["acronym"], name: "index_conferences_on_acronym"
    t.index ["parent_id"], name: "index_conferences_on_parent_id"
    t.index ["streaming"], name: "index_conferences_on_streaming", using: :gin
  end

  create_table "conferences_organizers", id: false, force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "organisation_id", null: false
    t.index ["conference_id"], name: "index_conferences_organizers_on_conference_id"
    t.index ["organisation_id"], name: "index_conferences_organizers_on_organisation_id"
  end

  create_table "event_view_counts", force: :cascade do |t|
    t.datetime "last_updated_at", precision: nil
  end

  create_table "events", force: :cascade do |t|
    t.integer "conference_id"
    t.datetime "created_at", precision: nil
    t.datetime "date", precision: nil
    t.text "description"
    t.string "doi"
    t.integer "downloaded_recordings_count", default: 0
    t.integer "duration", default: 0
    t.string "guid", limit: 255
    t.string "link", limit: 255
    t.jsonb "metadata", default: {}
    t.string "notes"
    t.string "original_language"
    t.bigint "parent_id"
    t.text "persons"
    t.string "poster_filename", limit: 255
    t.boolean "promoted"
    t.datetime "release_date", precision: nil
    t.jsonb "schedule", default: {}
    t.string "slug", limit: 255
    t.string "subtitle", limit: 255
    t.string "tags", default: [], null: false, array: true
    t.text "tags_yaml"
    t.string "thumb_filename", limit: 255
    t.string "thumbnails_filename", default: ""
    t.string "timeline_filename", default: ""
    t.string "title", limit: 255
    t.datetime "updated_at", precision: nil
    t.integer "view_count", default: 0
    t.index ["conference_id"], name: "index_events_on_conference_id"
    t.index ["guid"], name: "index_events_on_guid"
    t.index ["metadata"], name: "index_events_on_metadata", using: :gin
    t.index ["parent_id"], name: "index_events_on_parent_id"
    t.index ["release_date"], name: "index_events_on_release_date"
    t.index ["slug", "id"], name: "index_events_on_slug_and_id"
    t.index ["slug"], name: "index_events_on_slug"
    t.index ["title"], name: "index_events_on_title"
  end

  create_table "fasp_client_backfill_requests", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.bigint "fasp_client_provider_id", null: false
    t.integer "max_count"
    t.datetime "updated_at", null: false
    t.index ["fasp_client_provider_id"], name: "index_fasp_client_backfill_requests_on_fasp_client_provider_id"
  end

  create_table "fasp_client_event_subscriptions", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.bigint "fasp_client_provider_id", null: false
    t.string "subscription_type"
    t.datetime "updated_at", null: false
    t.index ["fasp_client_provider_id"], name: "idx_on_fasp_client_provider_id_dd4cdc071c"
  end

  create_table "fasp_client_providers", force: :cascade do |t|
    t.string "base_url"
    t.json "capabilities"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.string "ed25519_signing_key"
    t.string "fediverse_account"
    t.string "name"
    t.json "privacy_policy"
    t.string "public_key"
    t.string "server_id"
    t.string "sign_in_url"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.string "uuid"
  end

  create_table "news", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil
    t.date "date"
    t.string "title", limit: 255
    t.datetime "updated_at", precision: nil
  end

  create_table "organisations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "inception_date"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "wikidata_id"
    t.index ["name"], name: "index_organisations_on_name", unique: true
    t.index ["wikidata_id"], name: "index_organisations_on_wikidata_id", unique: true, where: "(wikidata_id IS NOT NULL)"
  end

  create_table "recording_views", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "identifier", default: ""
    t.integer "recording_id"
    t.datetime "updated_at", precision: nil
    t.string "user_agent", default: ""
    t.index ["recording_id"], name: "index_recording_views_on_recording_id"
  end

  create_table "recordings", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "event_id"
    t.string "filename", limit: 255
    t.string "folder", limit: 255
    t.integer "height"
    t.boolean "high_quality", default: true, null: false
    t.boolean "html5", default: false, null: false
    t.string "language", default: "eng"
    t.integer "length", comment: "duration in seconds"
    t.string "mime_type", limit: 255
    t.bigint "size", comment: "file size in bytes"
    t.string "state", limit: 255, default: "new", null: false
    t.boolean "translated", default: false, null: false
    t.datetime "updated_at", precision: nil
    t.integer "width"
    t.index ["event_id"], name: "index_recordings_on_event_id"
    t.index ["filename"], name: "index_recordings_on_filename"
    t.index ["mime_type"], name: "index_recordings_on_mime_type"
    t.index ["state", "mime_type"], name: "index_recordings_on_state_and_mime_type"
    t.index ["state"], name: "index_recordings_on_state"
  end

  create_table "site_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "live_banner_url"
    t.string "logo_alt"
    t.string "logo_url"
    t.string "promoted_banner_url"
    t.datetime "updated_at", null: false
  end

  create_table "web_feeds", force: :cascade do |t|
    t.text "content"
    t.string "key"
    t.string "kind"
    t.datetime "last_build", precision: nil
    t.index ["key", "kind"], name: "index_web_feeds_on_key_and_kind", unique: true
  end

  add_foreign_key "conferences", "conferences", column: "parent_id"
  add_foreign_key "events", "events", column: "parent_id"
  add_foreign_key "fasp_client_backfill_requests", "fasp_client_providers"
  add_foreign_key "fasp_client_event_subscriptions", "fasp_client_providers"
end
