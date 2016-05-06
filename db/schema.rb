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

ActiveRecord::Schema.define(version: 20160506054844) do

  create_table "artists", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "artists", ["name"], name: "index_artists_on_name", unique: true, using: :btree

  create_table "artists_users", id: false, force: :cascade do |t|
    t.integer "artist_id", limit: 4, null: false
    t.integer "user_id",   limit: 4, null: false
  end

  add_index "artists_users", ["artist_id", "user_id"], name: "index_artists_users_on_artist_id_and_user_id", unique: true, using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,                   null: false
    t.integer  "artist_id",    limit: 4,                   null: false
    t.string   "video_id",     limit: 255,                 null: false
    t.string   "title",        limit: 255,                 null: false
    t.datetime "date",                                     null: false
    t.boolean  "is_delivered",             default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "deliveries", ["artist_id"], name: "index_deliveries_on_artist_id", using: :btree
  add_index "deliveries", ["user_id"], name: "index_deliveries_on_user_id", using: :btree

  create_table "facebooks", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,   null: false
    t.string   "facebook_user_id", limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "facebooks", ["user_id", "facebook_user_id"], name: "index_facebooks_on_user_id_and_facebook_user_id", unique: true, using: :btree

  create_table "passwords", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,   null: false
    t.string   "password_digest", limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "passwords", ["user_id"], name: "index_passwords_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",         limit: 255, default: "",                    null: false
    t.string   "locale",        limit: 255, default: "en_US",               null: false
    t.integer  "timezone",      limit: 1,   default: 0,                     null: false
    t.time     "delivery_time",             default: '2000-01-01 08:00:00', null: false
    t.boolean  "is_active",                 default: true,                  null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "deliveries", "artists"
  add_foreign_key "deliveries", "users"
  add_foreign_key "facebooks", "users"
  add_foreign_key "passwords", "users"
end
