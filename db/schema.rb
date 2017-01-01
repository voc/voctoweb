# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161231215656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "key",         limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conferences", force: :cascade do |t|
    t.string   "acronym",                 limit: 255
    t.string   "recordings_path",         limit: 255
    t.string   "images_path",             limit: 255
    t.string   "slug",                    limit: 255, default: ""
    t.string   "aspect_ratio",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                   limit: 255
    t.string   "schedule_url",            limit: 255
    t.text     "schedule_xml"
    t.string   "schedule_state",          limit: 255, default: "not_present", null: false
    t.string   "logo",                    limit: 255
    t.integer  "downloaded_events_count",             default: 0,             null: false
    t.jsonb    "metadata",                            default: {}
    t.date     "event_last_released_at"
    t.index ["acronym"], name: "index_conferences_on_acronym", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.string   "guid",                        limit: 255
    t.string   "poster_filename",             limit: 255
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                       limit: 255
    t.string   "thumb_filename",              limit: 255
    t.datetime "date"
    t.text     "description"
    t.string   "link",                        limit: 255
    t.text     "persons"
    t.string   "slug",                        limit: 255
    t.string   "subtitle",                    limit: 255
    t.text     "tags"
    t.date     "release_date"
    t.boolean  "promoted"
    t.integer  "view_count",                              default: 0
    t.integer  "duration",                                default: 0
    t.integer  "downloaded_recordings_count",             default: 0
    t.string   "original_language"
    t.jsonb    "metadata",                                default: {}
    t.index ["conference_id"], name: "index_events_on_conference_id", using: :btree
    t.index ["guid"], name: "index_events_on_guid", using: :btree
    t.index ["metadata"], name: "index_events_on_metadata", using: :gin
    t.index ["release_date"], name: "index_events_on_release_date", using: :btree
    t.index ["slug", "id"], name: "index_events_on_slug_and_id", using: :btree
    t.index ["slug"], name: "index_events_on_slug", using: :btree
    t.index ["title"], name: "index_events_on_title", using: :btree
  end

  create_table "news", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recording_views", force: :cascade do |t|
    t.integer  "recording_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["recording_id"], name: "index_recording_views_on_recording_id", using: :btree
  end

  create_table "recordings", force: :cascade do |t|
    t.integer  "size"
    t.integer  "length"
    t.string   "mime_type",    limit: 255
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename",     limit: 255
    t.string   "state",        limit: 255, default: "new", null: false
    t.string   "folder",       limit: 255
    t.integer  "width"
    t.integer  "height"
    t.string   "language",                 default: "eng"
    t.boolean  "high_quality",             default: true,  null: false
    t.boolean  "html5",                    default: false, null: false
    t.index ["event_id"], name: "index_recordings_on_event_id", using: :btree
    t.index ["filename"], name: "index_recordings_on_filename", using: :btree
    t.index ["mime_type"], name: "index_recordings_on_mime_type", using: :btree
    t.index ["state", "mime_type"], name: "index_recordings_on_state_and_mime_type", using: :btree
    t.index ["state"], name: "index_recordings_on_state", using: :btree
  end

end
