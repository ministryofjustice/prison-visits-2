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

ActiveRecord::Schema.define(version: 20151110102448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_visitors", force: :cascade do |t|
    t.integer  "visit_id",      null: false
    t.string   "first_name",    null: false
    t.string   "last_name",     null: false
    t.date     "date_of_birth", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "additional_visitors", ["visit_id"], name: "index_additional_visitors_on_visit_id", using: :btree

  create_table "prisons", force: :cascade do |t|
    t.string   "name",                                    null: false
    t.string   "nomis_id",       limit: 3,                null: false
    t.boolean  "enabled",                  default: true, null: false
    t.integer  "booking_window",           default: 28,   null: false
    t.text     "address"
    t.string   "email_address"
    t.string   "phone_no"
    t.json     "slot_details",             default: {},   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "estate",                                  null: false
  end

  create_table "visits", force: :cascade do |t|
    t.integer  "prison_id",                                    null: false
    t.string   "prisoner_first_name",                          null: false
    t.string   "prisoner_last_name",                           null: false
    t.date     "prisoner_date_of_birth",                       null: false
    t.string   "prisoner_number",                              null: false
    t.string   "visitor_first_name",                           null: false
    t.string   "visitor_last_name",                            null: false
    t.date     "visitor_date_of_birth",                        null: false
    t.string   "visitor_email_address",                        null: false
    t.string   "visitor_phone_no",                             null: false
    t.string   "slot_option_1",                                null: false
    t.string   "slot_option_2"
    t.string   "slot_option_3"
    t.string   "slot_granted"
    t.string   "processing_state",       default: "requested", null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "reference_number",                             null: false
  end

  add_index "visits", ["prison_id"], name: "index_visits_on_prison_id", using: :btree

  add_foreign_key "additional_visitors", "visits"
  add_foreign_key "visits", "prisons"
end
