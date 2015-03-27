# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150326083215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string  "line_1",   limit: 255
    t.string  "line_2",   limit: 255
    t.string  "city",     limit: 100
    t.string  "state",    limit: 100
    t.string  "country",  limit: 100
    t.integer "zip_code"
    t.integer "user_id",              null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "artist_crowd_support_levels", force: :cascade do |t|
    t.integer  "artist_id",                       null: false
    t.integer  "crowd_id",                        null: false
    t.integer  "crowd_doer_level_id",             null: false
    t.integer  "trashed",             default: 0, null: false
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "artist_goals", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.float    "goal_amount",               null: false
    t.float    "raised_amount",             null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "sharing_goal",  default: 0
  end

  add_index "artist_goals", ["goal_amount"], name: "idx_artist_goals_on_goal_amount", using: :btree
  add_index "artist_goals", ["raised_amount"], name: "idx_artist_goals_on_rasied_amount", using: :btree
  add_index "artist_goals", ["user_id"], name: "idx_artist_goals_on_user_id", using: :btree

  create_table "crowd_doer_levels", force: :cascade do |t|
    t.string   "level_name",       limit: 255,              null: false
    t.string   "level_desc",       limit: 2048
    t.integer  "shares",                                    null: false
    t.float    "funding",                                   null: false
    t.string   "perks",            limit: 256
    t.integer  "max_participants"
    t.integer  "trashed",                       default: 0, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.integer  "event_id",                                   null: false
    t.string   "discount_token",  limit: 255,                null: false
    t.string   "discount_type",   limit: 255,                null: false
    t.float    "discount_value",              default: 0.0,  null: false
    t.datetime "valid_from_time",                            null: false
    t.datetime "valid_till_time"
    t.boolean  "is_active",                   default: true, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "title",              limit: 256
    t.string   "description",        limit: 512
    t.integer  "user_id",                                      null: false
    t.string   "venue",              limit: 512
    t.integer  "total_seats",                    default: 0,   null: false
    t.string   "event_type",         limit: 20,                null: false
    t.datetime "start_time",                                   null: false
    t.datetime "end_time",                                     null: false
    t.float    "price_per_seat",                 default: 0.0, null: false
    t.integer  "trashed",                        default: 0,   null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "opentok_session_id", limit: 512
    t.string   "image",              limit: 255, default: ""
  end

  add_index "events", ["end_time"], name: "idx_events_on_end_time", using: :btree
  add_index "events", ["opentok_session_id"], name: "idx_events_opentok_session", using: :btree
  add_index "events", ["opentok_session_id"], name: "idx_opentok_details_on_opentok_session_id", using: :btree
  add_index "events", ["start_time"], name: "idx_events_on_start_time", using: :btree
  add_index "events", ["user_id"], name: "idx_events_on_user_id", using: :btree

  create_table "hangout_media", force: :cascade do |t|
    t.integer  "user_id",                            null: false
    t.integer  "event_id",                           null: false
    t.integer  "media_type",                         null: false
    t.string   "url",        limit: 512,             null: false
    t.integer  "trashed",                default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "hangout_media", ["event_id"], name: "idx_hangout_media_on_event_id", using: :btree
  add_index "hangout_media", ["media_type"], name: "idx_hangout_media_on_media_type", using: :btree
  add_index "hangout_media", ["user_id", "event_id", "trashed"], name: "index_hangout_media_on_user_id_and_event_id_and_trashed", using: :btree
  add_index "hangout_media", ["user_id"], name: "idx_hangout_media_on_user_id", using: :btree

  create_table "hangout_messages", force: :cascade do |t|
    t.integer  "user_id",                                   null: false
    t.integer  "event_id",                                  null: false
    t.string   "message_type", limit: 255,                  null: false
    t.string   "message_body", limit: 2048,                 null: false
    t.boolean  "is_artist",                 default: false, null: false
    t.integer  "trashed",                   default: 0,     null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "hangout_messages", ["event_id"], name: "index_hangout_messages_on_event_id", using: :btree
  add_index "hangout_messages", ["trashed"], name: "index_hangout_messages_on_trashed", using: :btree
  add_index "hangout_messages", ["user_id"], name: "index_hangout_messages_on_user_id", using: :btree

  create_table "media", force: :cascade do |t|
    t.integer  "user_id",                             null: false
    t.integer  "media_type",                          null: false
    t.string   "title",      limit: 250,              null: false
    t.string   "desc",       limit: 512
    t.string   "url",        limit: 512,              null: false
    t.string   "meta_data",  limit: 1024
    t.integer  "trashed",                 default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "media", ["user_id"], name: "idx_media_on_user_id", using: :btree

  create_table "network_activity_logs", force: :cascade do |t|
    t.integer  "from_user_id",                               null: false
    t.integer  "object_id",                                  null: false
    t.string   "object_type",        limit: 255,             null: false
    t.integer  "dest_object_id",                             null: false
    t.string   "dest_object_type",   limit: 255,             null: false
    t.integer  "activity_type",                              null: false
    t.integer  "for_user_id",                                null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "reachability_count",             default: 1
  end

  add_index "network_activity_logs", ["for_user_id"], name: "idx_network_activity_on_for_user_id", using: :btree
  add_index "network_activity_logs", ["from_user_id"], name: "idx_network_activity_on_from_user_id", using: :btree

  create_table "opentok_details", force: :cascade do |t|
    t.integer  "user_id",                      null: false
    t.integer  "event_id",                     null: false
    t.string   "session_id",       limit: 512, null: false
    t.string   "ticket_code",      limit: 16,  null: false
    t.string   "token",            limit: 512
    t.datetime "token_expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "opentok_details", ["event_id"], name: "idx_opentok_details_on_event_id", using: :btree
  add_index "opentok_details", ["session_id"], name: "idx_opentok_details_on_session_id", using: :btree
  add_index "opentok_details", ["ticket_code"], name: "idx_opentok_details_on_ticket_code", using: :btree
  add_index "opentok_details", ["token_expires_at"], name: "idx_opentok_details_on_token_expires_at", using: :btree
  add_index "opentok_details", ["user_id"], name: "idx_opentok_details_on_user_id", using: :btree

  create_table "payment_details", force: :cascade do |t|
    t.integer  "user_id",                           null: false
    t.integer  "artist_id",                         null: false
    t.float    "amount",                            null: false
    t.string   "stripe_token",          limit: 255, null: false
    t.string   "stripe_customer_id",    limit: 255, null: false
    t.string   "payment_reason",        limit: 255, null: false
    t.string   "status",                limit: 255, null: false
    t.string   "payment_failed_reason", limit: 255
    t.integer  "trashed",                           null: false
    t.string   "currency",              limit: 255, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "payment_details", ["artist_id"], name: "idx_payment_details_on_artist_id", using: :btree
  add_index "payment_details", ["status"], name: "idx_payment_details_on_status", using: :btree
  add_index "payment_details", ["stripe_customer_id"], name: "idx_payment_details_on_stripe_customer_id", using: :btree
  add_index "payment_details", ["trashed"], name: "idx_payment_details_on_trashed", using: :btree
  add_index "payment_details", ["user_id"], name: "idx_payment_details_on_user_id", using: :btree

  create_table "phase_ledgers", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "phase"
    t.integer  "trashed",        default: 0, null: false
    t.datetime "activated_at",               null: false
    t.datetime "deactivated_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "phase_ledgers", ["user_id"], name: "idx_phase_ledgers_on_user_id", using: :btree

  create_table "playlist_songs", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "playlist_id", null: false
    t.integer  "media_id",    null: false
    t.integer  "trashed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "playlist_songs", ["media_id"], name: "idx_playlist_songs_on_media_id", using: :btree
  add_index "playlist_songs", ["playlist_id"], name: "idx_playlist_songs_on_playlist_id", using: :btree
  add_index "playlist_songs", ["user_id"], name: "idx_playlist_songs_on_user_id", using: :btree

  create_table "playlists", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "playlist_name", limit: 255, null: false
    t.integer  "trashed"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "playlists", ["trashed"], name: "idx_playlists_on_trashed", using: :btree
  add_index "playlists", ["user_id"], name: "idx_playlists_on_user_id", using: :btree

  create_table "rewards", force: :cascade do |t|
    t.integer  "user_id",                                null: false
    t.integer  "artist_goal_id",                         null: false
    t.float    "amount",                                 null: false
    t.string   "comment",        limit: 255,             null: false
    t.integer  "trashed",                    default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "rewards", ["artist_goal_id"], name: "idx_rewards_on_artist_goal_id", using: :btree
  add_index "rewards", ["user_id"], name: "idx_rewards_on_user_id", using: :btree

  create_table "social_connects", force: :cascade do |t|
    t.integer  "user_id",                  null: false
    t.string   "network_id",   limit: 100, null: false
    t.string   "access_token", limit: 255, null: false
    t.integer  "network_type",             null: false
    t.string   "screen_name",  limit: 250
    t.string   "secret",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "social_connects", ["access_token"], name: "idx_social_connects_on_access_token", using: :btree
  add_index "social_connects", ["user_id", "network_id"], name: "idx_social_connects_on_user_id_and_network_id", using: :btree
  add_index "social_connects", ["user_id"], name: "idx_social_connects_on_user_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "event_id",                    null: false
    t.integer  "user_id",                     null: false
    t.string   "ticket_token",    limit: 255, null: false
    t.datetime "booked_at",                   null: false
    t.integer  "payment_txn_id"
    t.string   "discount_token",  limit: 255
    t.float    "selling_price",               null: false
    t.string   "status",          limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "opentok_role",    limit: 30
    t.string   "user_role",       limit: 30
    t.integer  "used_by_user_id"
  end

  add_index "tickets", ["event_id"], name: "idx_tickets_on_event_id", using: :btree
  add_index "tickets", ["opentok_role"], name: "idx_opentok_details_on_opentok_role", using: :btree
  add_index "tickets", ["ticket_token"], name: "idx_tickets_on_ticket_token", using: :btree
  add_index "tickets", ["used_by_user_id"], name: "idx_opentok_details_on_used_by_user_id", using: :btree
  add_index "tickets", ["user_id"], name: "idx_tickets_on_user_id", using: :btree
  add_index "tickets", ["user_role"], name: "idx_opentok_details_on_user_role", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                  limit: 20,                null: false
    t.string   "last_name",                   limit: 20,                null: false
    t.string   "email",                       limit: 50,                null: false
    t.string   "phone_number",                limit: 10,                null: false
    t.string   "avatar",                      limit: 255
    t.string   "bg_image",                    limit: 255
    t.string   "bio",                         limit: 512
    t.string   "desc",                        limit: 1024
    t.integer  "user_type",                                default: 1
    t.string   "stage_name",                  limit: 20
    t.string   "password_digest",             limit: 512,  default: ""
    t.string   "reset_password_token",        limit: 512
    t.datetime "password_reset_requested_at"
    t.integer  "trashed",                                  default: 0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "artist_card_bg_image",        limit: 255
    t.string   "crowd_role_chosen",           limit: 30
  end

  add_index "users", ["email"], name: "idx_users_on_email", using: :btree
  add_index "users", ["phone_number"], name: "idx_users_phone_number", using: :btree
  add_index "users", ["reset_password_token"], name: "idx_users_reset_password_token", using: :btree

end
