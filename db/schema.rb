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

ActiveRecord::Schema.define(version: 20150401112444) do

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

  create_table "adresses", force: :cascade do |t|
    t.string  "line_1"
    t.string  "line_2"
    t.string  "city",     limit: 100
    t.string  "state",    limit: 100
    t.string  "country",  limit: 100
    t.integer "zip_code"
    t.integer "user_id",  null: false
  end

  create_table "artist_crowd_support_levels", force: :cascade do |t|
    t.integer  "artist_id",           null: false
    t.integer  "crowd_id",            null: false
    t.integer  "crowd_doer_level_id", null: false
    t.integer  "trashed",             default: 0, null: false
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_goals", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.float    "goal_amount",   null: false
    t.float    "raised_amount", null: false
    t.integer  "sharing_goal",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "artist_goals", ["goal_amount"], name: "idx_artist_goals_on_goal_amount", using: :btree
  add_index "artist_goals", ["raised_amount"], name: "idx_artist_goals_on_rasied_amount", using: :btree
  add_index "artist_goals", ["user_id"], name: "idx_artist_goals_on_user_id", using: :btree

  create_table "crowd_doer_levels", force: :cascade do |t|
    t.string   "level_name",       null: false
    t.string   "level_desc",       limit: 2048
    t.integer  "shares",           null: false
    t.float    "funding",          null: false
    t.string   "perks",            limit: 256
    t.integer  "max_participants"
    t.integer  "trashed",          default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", force: :cascade do |t|
    t.integer  "event_id",        null: false
    t.string   "discount_token",  null: false
    t.string   "discount_type",   null: false
    t.float    "discount_value",  default: 0.0,  null: false
    t.datetime "valid_from_time", null: false
    t.datetime "valid_till_time"
    t.boolean  "is_active",       default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "title",              limit: 256
    t.string   "description",        limit: 512
    t.integer  "user_id",            null: false
    t.string   "venue",              limit: 512
    t.integer  "total_seats",        default: 0,   null: false
    t.string   "event_type",         limit: 20,                null: false
    t.datetime "start_time",         null: false
    t.datetime "end_time",           null: false
    t.float    "price_per_seat",     default: 0.0, null: false
    t.integer  "trashed",            default: 0,   null: false
    t.string   "opentok_session_id", limit: 512
    t.string   "image",              default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "events", ["end_time"], name: "idx_events_on_end_time", using: :btree
  add_index "events", ["opentok_session_id"], name: "idx_events_opentok_session", using: :btree
  add_index "events", ["start_time"], name: "idx_events_on_start_time", using: :btree
  add_index "events", ["user_id"], name: "idx_events_on_user_id", using: :btree

  create_table "hangout_media", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "event_id",   null: false
    t.integer  "media_type", null: false
    t.string   "url",        limit: 512,             null: false
    t.integer  "trashed",    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "hangout_media", ["event_id"], name: "idx_hangout_media_on_event_id", using: :btree
  add_index "hangout_media", ["media_type"], name: "idx_hangout_media_on_media_type", using: :btree
  add_index "hangout_media", ["user_id"], name: "idx_hangout_media_on_user_id", using: :btree

  create_table "hangout_messages", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "event_id",     null: false
    t.string   "message_type", null: false
    t.string   "message_body", limit: 2048,                 null: false
    t.boolean  "is_artist",    default: false, null: false
    t.integer  "trashed",      default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "hangout_messages", ["event_id"], name: "index_hangout_messages_on_event_id", using: :btree
  add_index "hangout_messages", ["trashed"], name: "index_hangout_messages_on_trashed", using: :btree
  add_index "hangout_messages", ["user_id"], name: "index_hangout_messages_on_user_id", using: :btree

  create_table "network_activity_logs", force: :cascade do |t|
    t.integer  "from_user_id",       null: false
    t.integer  "object_id",          null: false
    t.string   "object_type",        null: false
    t.integer  "dest_object_id",     null: false
    t.string   "dest_object_type",   null: false
    t.integer  "activity_type",      null: false
    t.integer  "for_user_id",        null: false
    t.integer  "reachability_count", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "network_activity_logs", ["for_user_id"], name: "idx_network_activity_on_for_user_id", using: :btree
  add_index "network_activity_logs", ["from_user_id"], name: "idx_network_activity_on_from_user_id", using: :btree

  create_view "like_share_view", " SELECT v.object_id,\n    v.object_type,\n    v.for_user_id,\n    max(\n        CASE\n            WHEN (v.activity_type = 1) THEN v.activity_count\n            ELSE (0)::bigint\n        END) AS plays,\n    max(\n        CASE\n            WHEN (v.activity_type = 2) THEN v.activity_count\n            ELSE (0)::bigint\n        END) AS likes,\n    max(\n        CASE\n            WHEN (v.activity_type = 3) THEN v.activity_count\n            ELSE (0)::bigint\n        END) AS shares,\n    max(\n        CASE\n            WHEN (v.activity_type = 1) THEN v.user_count\n            ELSE (0)::bigint\n        END) AS users_played,\n    max(\n        CASE\n            WHEN (v.activity_type = 2) THEN v.user_count\n            ELSE (0)::bigint\n        END) AS users_liked,\n    max(\n        CASE\n            WHEN (v.activity_type = 3) THEN v.user_count\n            ELSE (0)::bigint\n        END) AS users_shared\n   FROM ( SELECT network_activity_logs.object_id,\n            network_activity_logs.activity_type,\n            network_activity_logs.object_type,\n            network_activity_logs.for_user_id,\n            sum(network_activity_logs.reachability_count) AS activity_count,\n            count(1) AS user_count\n           FROM network_activity_logs\n          GROUP BY network_activity_logs.object_id, network_activity_logs.activity_type, network_activity_logs.object_type, network_activity_logs.for_user_id\n          ORDER BY network_activity_logs.object_id, network_activity_logs.activity_type) v\n  GROUP BY v.object_id, v.object_type, v.for_user_id\n  ORDER BY v.object_id, v.object_type", :force => true
  create_table "media", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "media_type", null: false
    t.string   "title",      limit: 250,              null: false
    t.string   "desc",       limit: 512
    t.string   "url",        limit: 512,              null: false
    t.string   "meta_data",  limit: 1024
    t.integer  "trashed",    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "media", ["user_id"], name: "idx_media_on_user_id", using: :btree

  create_table "opentok_details", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.integer  "event_id",         null: false
    t.string   "session_id",       limit: 512, null: false
    t.string   "ticket_code",      limit: 16,  null: false
    t.string   "token",            limit: 512
    t.datetime "token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "opentok_details", ["event_id"], name: "idx_opentok_details_on_event_id", using: :btree
  add_index "opentok_details", ["session_id"], name: "idx_opentok_details_on_session_id", using: :btree
  add_index "opentok_details", ["ticket_code"], name: "idx_opentok_details_on_ticket_code", using: :btree
  add_index "opentok_details", ["token_expires_at"], name: "idx_opentok_details_on_token_expires_at", using: :btree
  add_index "opentok_details", ["user_id"], name: "idx_opentok_details_on_user_id", using: :btree

  create_table "payment_details", force: :cascade do |t|
    t.integer  "user_id",               null: false
    t.integer  "artist_id",             null: false
    t.float    "amount",                null: false
    t.string   "stripe_token",          null: false
    t.string   "stripe_customer_id",    null: false
    t.string   "payment_reason",        null: false
    t.string   "status",                null: false
    t.string   "payment_failed_reason"
    t.integer  "trashed",               null: false
    t.string   "currency",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "payment_details", ["artist_id"], name: "idx_payment_details_on_artist_id", using: :btree
  add_index "payment_details", ["status"], name: "idx_payment_details_on_status", using: :btree
  add_index "payment_details", ["stripe_customer_id"], name: "idx_payment_details_on_stripe_customer_id", using: :btree
  add_index "payment_details", ["trashed"], name: "idx_payment_details_on_trashed", using: :btree
  add_index "payment_details", ["user_id"], name: "idx_payment_details_on_user_id", using: :btree

  create_table "phase_ledgers", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "phase"
    t.integer  "trashed",        default: 0, null: false
    t.datetime "activated_at",   null: false
    t.datetime "deactivated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "phase_ledgers", ["user_id"], name: "idx_phase_ledgers_on_user_id", using: :btree

  create_table "playlist_songs", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "playlist_id", null: false
    t.integer  "media_id",    null: false
    t.integer  "trashed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "playlist_songs", ["media_id"], name: "idx_playlist_songs_on_media_id", using: :btree
  add_index "playlist_songs", ["playlist_id"], name: "idx_playlist_songs_on_playlist_id", using: :btree
  add_index "playlist_songs", ["user_id"], name: "idx_playlist_songs_on_user_id", using: :btree

  create_table "playlists", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "playlist_name", null: false
    t.integer  "trashed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "playlists", ["trashed"], name: "idx_playlists_on_trashed", using: :btree
  add_index "playlists", ["user_id"], name: "idx_playlists_on_user_id", using: :btree

  create_table "rewards", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "artist_goal_id", null: false
    t.float    "amount",         null: false
    t.string   "comment",        null: false
    t.integer  "trashed",        default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "rewards", ["artist_goal_id"], name: "idx_rewards_on_artist_goal_id", using: :btree
  add_index "rewards", ["user_id"], name: "idx_rewards_on_user_id", using: :btree

  create_table "social_connects", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.string   "network_id",   limit: 100, null: false
    t.string   "access_token", null: false
    t.integer  "network_type", null: false
    t.string   "screen_name",  limit: 250
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "social_connects", ["access_token"], name: "idx_social_connects_on_access_token", using: :btree
  add_index "social_connects", ["user_id", "network_id"], name: "idx_social_connects_on_user_id_and_network_id", using: :btree
  add_index "social_connects", ["user_id"], name: "idx_social_connects_on_user_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "event_id",        null: false
    t.integer  "user_id",         null: false
    t.string   "ticket_token",    null: false
    t.datetime "booked_at",       null: false
    t.integer  "payment_txn_id"
    t.string   "discount_token"
    t.float    "selling_price",   null: false
    t.string   "status",          null: false
    t.string   "opentok_role",    limit: 30
    t.string   "user_role",       limit: 30
    t.integer  "used_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "avatar"
    t.string   "bg_image"
    t.string   "bio",                         limit: 512
    t.string   "desc",                        limit: 1024
    t.integer  "user_type",                   default: 1
    t.string   "stage_name",                  limit: 20
    t.string   "password_digest",             limit: 512,  default: ""
    t.string   "reset_password_token",        limit: 512
    t.datetime "password_reset_requested_at"
    t.integer  "trashed",                     default: 0
    t.string   "artist_card_bg_image"
    t.string   "crowd_role_chosen",           limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "users", ["email"], name: "idx_users_on_email", using: :btree
  add_index "users", ["phone_number"], name: "idx_users_phone_number", using: :btree
  add_index "users", ["reset_password_token"], name: "idx_users_reset_password_token", using: :btree

  create_view "vw_artists", " SELECT users.id,\n    users.first_name,\n    users.last_name,\n    users.email,\n    users.phone_number,\n    users.avatar,\n    users.bg_image,\n    users.bio,\n    users.\"desc\",\n    users.user_type,\n    users.stage_name,\n    users.artist_card_bg_image,\n    users.crowd_role_chosen,\n    phase_ledgers.phase AS phase_id,\n    COALESCE(sum(like_share_view.likes), (0)::numeric) AS likes,\n    COALESCE(sum(like_share_view.shares), (0)::numeric) AS shares,\n    COALESCE(sum(like_share_view.plays), (0)::numeric) AS plays,\n    COALESCE(sum(like_share_view.users_shared), (0)::numeric) AS users_shared,\n    COALESCE(vw_ticket.total_tickets, (0)::bigint) AS total_tickets,\n    COALESCE(vw_supporters.total_number_supporters, (0)::bigint) AS number_of_supporters,\n    COALESCE(vw_supporters.pledged_amount, (0)::double precision) AS pledged_amount,\n    COALESCE(artist_goals.goal_amount, (0)::double precision) AS goal_amount,\n    COALESCE(artist_goals.sharing_goal, 0) AS sharing_goal,\n    vw_images.images,\n    users.created_at,\n    users.updated_at\n   FROM ((((((users\n     LEFT JOIN phase_ledgers ON (((phase_ledgers.user_id = users.id) AND (phase_ledgers.trashed = 0))))\n     LEFT JOIN like_share_view ON ((users.id = like_share_view.for_user_id)))\n     LEFT JOIN ( SELECT events.user_id,\n            count(1) AS total_tickets\n           FROM events,\n            tickets\n          WHERE ((tickets.event_id = events.id) AND ((tickets.status)::text = 'booked'::text))\n          GROUP BY events.user_id) vw_ticket ON ((vw_ticket.user_id = users.id)))\n     LEFT JOIN ( SELECT payment_details.artist_id,\n            count(1) AS total_number_supporters,\n            sum(payment_details.amount) AS pledged_amount\n           FROM payment_details\n          WHERE ((payment_details.status)::text = ANY ((ARRAY['u'::character varying, 'c'::character varying])::text[]))\n          GROUP BY payment_details.artist_id) vw_supporters ON ((vw_supporters.artist_id = users.id)))\n     LEFT JOIN ( SELECT media.user_id,\n            array_agg(media.url) AS images\n           FROM media\n          WHERE ((media.media_type = 0) AND (media.trashed = 0))\n          GROUP BY media.user_id) vw_images ON ((users.id = vw_images.user_id)))\n     LEFT JOIN artist_goals ON ((artist_goals.user_id = users.id)))\n  WHERE (users.trashed = 0)\n  GROUP BY users.id, users.first_name, users.last_name, users.email, users.phone_number, users.avatar, users.bg_image, users.bio, users.\"desc\", users.user_type, users.stage_name, users.artist_card_bg_image, phase_ledgers.phase, vw_ticket.total_tickets, vw_supporters.total_number_supporters, vw_images.images, users.created_at, users.updated_at, vw_supporters.pledged_amount, artist_goals.goal_amount, artist_goals.sharing_goal, users.crowd_role_chosen", :force => true
  create_view "vw_events", " SELECT events.id,\n    events.user_id,\n    events.title,\n    events.description,\n    events.total_seats,\n    events.event_type,\n    events.start_time,\n    events.end_time,\n    events.price_per_seat,\n    events.image,\n    users.avatar AS artist_avatar,\n    users.first_name AS artist_first_name,\n    users.last_name AS artist_last_name,\n    events.opentok_session_id,\n    COALESCE(q.tickets_sold, (0)::bigint) AS tickets_sold\n   FROM ((events\n     JOIN users ON (((((users.id = events.user_id) AND (events.trashed = 0)) AND (users.trashed = 0)) AND (users.user_type > 0))))\n     LEFT JOIN ( SELECT tickets.event_id,\n            count(1) AS tickets_sold\n           FROM tickets\n          WHERE ((tickets.status)::text = ANY ((ARRAY['pending'::character varying, 'booked'::character varying, 'viewing'::character varying, 'used'::character varying])::text[]))\n          GROUP BY tickets.event_id) q ON (((q.event_id = events.id) AND (events.trashed = 0))))", :force => true
  create_view "vw_booked_events", " SELECT vw_events.id AS event_id,\n    tickets.user_id,\n    vw_events.title,\n    vw_events.description,\n    vw_events.total_seats,\n    vw_events.event_type,\n    vw_events.start_time,\n    vw_events.end_time,\n    vw_events.price_per_seat,\n    vw_events.artist_avatar,\n    vw_events.artist_first_name,\n    vw_events.artist_last_name,\n    vw_events.opentok_session_id,\n    vw_events.tickets_sold,\n    vw_events.image,\n    string_agg((tickets.ticket_token)::text, ','::text) AS tickets,\n    string_agg((tickets.opentok_role)::text, ','::text) AS ticket_roles\n   FROM (vw_events\n     JOIN tickets ON (((tickets.event_id = vw_events.id) AND ((tickets.status)::text = ANY ((ARRAY['booked'::character varying, 'viewing'::character varying, 'used'::character varying])::text[])))))\n  GROUP BY vw_events.id, tickets.user_id, vw_events.title, vw_events.description, vw_events.total_seats, vw_events.event_type, vw_events.start_time, vw_events.end_time, vw_events.price_per_seat, vw_events.artist_avatar, vw_events.artist_first_name, vw_events.artist_last_name, vw_events.opentok_session_id, vw_events.tickets_sold, vw_events.image", :force => true
  create_view "vw_crowd_activities", " SELECT network_activity_logs.from_user_id,\n    network_activity_logs.for_user_id,\n        CASE\n            WHEN (network_activity_logs.activity_type = 1) THEN 'plays'::text\n            WHEN (network_activity_logs.activity_type = 2) THEN 'likes'::text\n            WHEN (network_activity_logs.activity_type = 3) THEN 'shares'::text\n            ELSE NULL::text\n        END AS activity,\n    sum(network_activity_logs.reachability_count) AS sum\n   FROM network_activity_logs\n  GROUP BY network_activity_logs.from_user_id, network_activity_logs.for_user_id, network_activity_logs.activity_type\nUNION\n SELECT payment_details.user_id AS from_user_id,\n    payment_details.artist_id AS for_user_id,\n    'funding'::character varying AS activity,\n    sum(payment_details.amount) AS sum\n   FROM payment_details\n  WHERE (((payment_details.status)::text = ANY ((ARRAY['u'::character varying, 'c'::character varying])::text[])) AND (payment_details.trashed = 0))\n  GROUP BY payment_details.user_id, payment_details.artist_id, 'funding'::character varying", :force => true
  create_view "vw_crowd_supporters", " SELECT artist_crowd_support_levels.crowd_id,\n    users.first_name AS crowd_first_name,\n    users.last_name AS crowd_last_name,\n    users.email AS crowd_email,\n    artist_crowd_support_levels.artist_id,\n    artist_crowd_support_levels.crowd_doer_level_id AS support_level,\n    artist_crowd_support_levels.activated_at,\n    users.avatar AS crowd_avatar\n   FROM (artist_crowd_support_levels\n     JOIN users ON ((users.id = artist_crowd_support_levels.crowd_id)))\n  WHERE ((users.trashed = 0) AND (artist_crowd_support_levels.trashed = 0))", :force => true
  create_view "vw_payments", " SELECT artist_goals.user_id AS artist_id,\n    artist_goals.goal_amount,\n    sum(pay.pledged_amount) AS raised_amount,\n    phase_ledgers.phase,\n    max(\n        CASE\n            WHEN ((pay.status)::text = 'c'::text) THEN pay.pledged_amount\n            ELSE (0.0)::double precision\n        END) AS charged_amount,\n    max(\n        CASE\n            WHEN ((pay.status)::text = 'u'::text) THEN pay.pledged_amount\n            ELSE (0.0)::double precision\n        END) AS uncharged_amount\n   FROM ((artist_goals\n     JOIN phase_ledgers ON (((phase_ledgers.user_id = artist_goals.user_id) AND (phase_ledgers.trashed = 0))))\n     JOIN ( SELECT payment_details.artist_id,\n            payment_details.status,\n            sum(payment_details.amount) AS pledged_amount\n           FROM payment_details\n          GROUP BY payment_details.artist_id, payment_details.status) pay ON ((pay.artist_id = artist_goals.user_id)))\n  GROUP BY artist_goals.user_id, artist_goals.goal_amount, phase_ledgers.phase", :force => true
  create_view "vw_media", " SELECT media.id,\n    media.user_id,\n    media.media_type,\n    media.title,\n    media.\"desc\",\n    media.url,\n    media.meta_data,\n    media.created_at,\n    media.updated_at,\n    users.first_name,\n    users.last_name,\n    users.avatar,\n    users.artist_card_bg_image,\n    phase_ledgers.phase AS phase_id,\n    COALESCE(like_share_view.plays, (0)::bigint) AS plays,\n    COALESCE(like_share_view.likes, (0)::bigint) AS likes,\n    COALESCE(like_share_view.shares, (0)::bigint) AS shares,\n    COALESCE(vw_payments.raised_amount, (0)::double precision) AS raised_amount\n   FROM ((((media\n     JOIN users ON (((media.user_id = users.id) AND (users.trashed = 0))))\n     LEFT JOIN like_share_view ON (((media.id = like_share_view.object_id) AND ((like_share_view.object_type)::text = 'Media'::text))))\n     LEFT JOIN phase_ledgers ON (((phase_ledgers.user_id = media.user_id) AND (phase_ledgers.trashed = 0))))\n     LEFT JOIN vw_payments ON ((vw_payments.artist_id = media.user_id)))\n  WHERE (media.trashed = 0)", :force => true
  create_view "vw_nw_activity_counts", " SELECT network_activity_logs.object_id,\n    network_activity_logs.activity_type,\n    network_activity_logs.object_type,\n    count(1) AS activity_count\n   FROM network_activity_logs\n  GROUP BY network_activity_logs.object_id, network_activity_logs.activity_type, network_activity_logs.object_type", :force => true
  create_view "vw_playlists", " SELECT playlist_songs.id,\n    playlist_songs.media_id,\n    playlists.id AS playlist_id,\n    playlists.playlist_name,\n    playlists.user_id,\n    vw_media.meta_data,\n    vw_media.title,\n    vw_media.url,\n    vw_media.media_type,\n    vw_media.user_id AS artist_id,\n    vw_media.first_name AS artist_first_name,\n    vw_media.last_name AS artist_last_name,\n    vw_media.avatar AS artist_avatar,\n    vw_media.artist_card_bg_image,\n    vw_media.plays,\n    vw_media.likes,\n    vw_media.shares\n   FROM ((playlist_songs\n     JOIN playlists ON ((((playlists.id = playlist_songs.playlist_id) AND (playlist_songs.trashed = 0)) AND (playlists.trashed = 0))))\n     LEFT JOIN vw_media ON (((playlist_songs.media_id = vw_media.id) AND (playlist_songs.trashed = 0))))", :force => true
end
