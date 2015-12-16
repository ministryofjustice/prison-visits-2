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

ActiveRecord::Schema.define(version: 20151215105705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "feedback_submissions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "body",          null: false
    t.string   "email_address"
    t.string   "referrer"
    t.string   "user_agent"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "prisoners", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.date     "date_of_birth", null: false
    t.string   "number",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "prisons", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                                         null: false
    t.string   "nomis_id",           limit: 3,                 null: false
    t.boolean  "enabled",                      default: true,  null: false
    t.integer  "booking_window",               default: 28,    null: false
    t.text     "address"
    t.string   "estate"
    t.string   "email_address"
    t.string   "phone_no"
    t.json     "slot_details",                 default: {},    null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "lead_days",                    default: 3,     null: false
    t.boolean  "weekend_processing",           default: false, null: false
    t.integer  "adult_age",                                    null: false
    t.string   "finder_slug",                                  null: false
  end

  create_table "rejections", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "visit_id",                        null: false
    t.date     "allowance_renews_on"
    t.date     "privileged_allowance_expires_on"
    t.string   "reason",                          null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "rejections", ["visit_id"], name: "index_rejections_on_visit_id", unique: true, using: :btree

  create_table "visitors", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "visit_id",      null: false
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.date     "date_of_birth", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "sort_index",    null: false
    t.boolean  "banned"
    t.boolean  "not_on_list"
  end

  add_index "visitors", ["visit_id", "sort_index"], name: "index_visitors_on_visit_id_and_sort_index", unique: true, using: :btree
  add_index "visitors", ["visit_id"], name: "index_visitors_on_visit_id", using: :btree

  create_table "visits", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "prison_id",                                     null: false
    t.string   "contact_email_address",                         null: false
    t.string   "contact_phone_no",                              null: false
    t.string   "slot_option_0",                                 null: false
    t.string   "slot_option_1"
    t.string   "slot_option_2"
    t.string   "slot_granted"
    t.string   "processing_state",        default: "requested", null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "reference_no"
    t.boolean  "closed"
    t.boolean  "override_delivery_error", default: false
    t.string   "delivery_error_type"
    t.uuid     "prisoner_id",                                   null: false
  end

  add_index "visits", ["prison_id"], name: "index_visits_on_prison_id", using: :btree

  add_foreign_key "rejections", "visits"
  add_foreign_key "visitors", "visits"
  add_foreign_key "visits", "prisoners"
  add_foreign_key "visits", "prisons"
end
