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

ActiveRecord::Schema[7.0].define(version: 2023_01_31_143555) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace", limit: 255
    t.text "body"
    t.string "resource_id", limit: 255, null: false
    t.string "resource_type", limit: 255, null: false
    t.integer "author_id"
    t.string "author_type", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "key", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "conferences", force: :cascade do |t|
    t.string "acronym", limit: 255
    t.string "recordings_path", limit: 255
    t.string "images_path", limit: 255
    t.string "slug", limit: 255, default: ""
    t.string "aspect_ratio", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "title", limit: 255
    t.string "schedule_url", limit: 255
    t.text "schedule_xml"
    t.string "schedule_state", limit: 255, default: "not_present", null: false
    t.string "logo", limit: 255
    t.integer "downloaded_events_count", default: 0, null: false
    t.jsonb "metadata", default: {}
    t.datetime "event_last_released_at", precision: nil
    t.jsonb "streaming", default: {}
    t.text "description"
    t.string "link", limit: 255
    t.text "custom_css"
    t.index ["acronym"], name: "index_conferences_on_acronym"
    t.index ["streaming"], name: "index_conferences_on_streaming", using: :gin
  end

  create_table "event_view_counts", force: :cascade do |t|
    t.datetime "last_updated_at", precision: nil
  end

  create_table "events", force: :cascade do |t|
    t.string "guid", limit: 255
    t.string "poster_filename", limit: 255
    t.integer "conference_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "title", limit: 255
    t.string "thumb_filename", limit: 255
    t.datetime "date", precision: nil
    t.text "description"
    t.string "link", limit: 255
    t.text "persons"
    t.string "slug", limit: 255
    t.string "subtitle", limit: 255
    t.text "tags"
    t.datetime "release_date", precision: nil
    t.boolean "promoted"
    t.integer "view_count", default: 0
    t.integer "duration", default: 0
    t.integer "downloaded_recordings_count", default: 0
    t.string "original_language"
    t.jsonb "metadata", default: {}
    t.string "timeline_filename", default: ""
    t.string "thumbnails_filename", default: ""
    t.string "doi"
    t.index ["conference_id"], name: "index_events_on_conference_id"
    t.index ["guid"], name: "index_events_on_guid"
    t.index ["metadata"], name: "index_events_on_metadata", using: :gin
    t.index ["release_date"], name: "index_events_on_release_date"
    t.index ["slug", "id"], name: "index_events_on_slug_and_id"
    t.index ["slug"], name: "index_events_on_slug"
    t.index ["title"], name: "index_events_on_title"
  end

  create_table "news", force: :cascade do |t|
    t.string "title", limit: 255
    t.text "body"
    t.date "date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "recording_views", force: :cascade do |t|
    t.integer "recording_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "user_agent", default: ""
    t.string "identifier", default: ""
    t.index ["recording_id"], name: "index_recording_views_on_recording_id"
  end

  create_table "recordings", force: :cascade do |t|
    t.integer "size", comment: "approximate file size in megabytes"
    t.integer "length", comment: "duration in seconds"
    t.string "mime_type", limit: 255
    t.integer "event_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "filename", limit: 255
    t.string "state", limit: 255, default: "new", null: false
    t.string "folder", limit: 255
    t.integer "width"
    t.integer "height"
    t.string "language", default: "eng"
    t.boolean "high_quality", default: true, null: false
    t.boolean "html5", default: false, null: false
    t.index ["event_id"], name: "index_recordings_on_event_id"
    t.index ["filename"], name: "index_recordings_on_filename"
    t.index ["mime_type"], name: "index_recordings_on_mime_type"
    t.index ["state", "mime_type"], name: "index_recordings_on_state_and_mime_type"
    t.index ["state"], name: "index_recordings_on_state"
  end

  create_table "web_feeds", force: :cascade do |t|
    t.string "key"
    t.string "kind"
    t.datetime "last_build", precision: nil
    t.text "content"
    t.index ["key", "kind"], name: "index_web_feeds_on_key_and_kind", unique: true
  end

end
