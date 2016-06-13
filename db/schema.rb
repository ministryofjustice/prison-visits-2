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

ActiveRecord::Schema.define(version: 20160610101017) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "cancellations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "visit_id",   null: false
    t.string   "reason",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cancellations", ["visit_id"], name: "index_cancellations_on_visit_id", unique: true, using: :btree

  create_table "estates", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nomis_id",    limit: 3, null: false
    t.string   "finder_slug",           null: false
  end

  add_index "estates", ["name"], name: "index_estates_on_name", unique: true, using: :btree

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
    t.boolean  "enabled",                      default: true,  null: false
    t.integer  "booking_window",               default: 28,    null: false
    t.text     "address"
    t.string   "email_address"
    t.string   "phone_no"
    t.json     "slot_details",                 default: {},    null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "lead_days",                    default: 3,     null: false
    t.boolean  "weekend_processing",           default: false, null: false
    t.integer  "adult_age",                                    null: false
    t.uuid     "estate_id",                                    null: false
    t.json     "translations",                 default: {},    null: false
    t.string   "postcode",           limit: 8
  end

  add_index "prisons", ["estate_id"], name: "index_prisons_on_estate_id", using: :btree

  create_table "rejection_percentage_by_prison_and_calendar_weeks", force: :cascade do |t|
  end

  create_table "rejection_percentage_by_prisons", force: :cascade do |t|
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

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.uuid     "estate_id",                        null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["estate_id"], name: "index_users_on_estate_id", unique: true, using: :btree

  create_table "visit_state_changes", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "visit_state"
    t.uuid     "visit_id",    null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "visit_state_changes", ["visit_id"], name: "index_visit_state_changes_on_visit_id", using: :btree

  create_table "visitors", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "visit_id",                      null: false
    t.string   "first_name",                    null: false
    t.string   "last_name",                     null: false
    t.date     "date_of_birth",                 null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "sort_index",                    null: false
    t.boolean  "banned",        default: false
    t.boolean  "not_on_list",   default: false
  end

  add_index "visitors", ["visit_id", "sort_index"], name: "index_visitors_on_visit_id_and_sort_index", unique: true, using: :btree
  add_index "visitors", ["visit_id"], name: "index_visitors_on_visit_id", using: :btree

  create_table "visits", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "prison_id",                                               null: false
    t.string   "contact_email_address",                                   null: false
    t.string   "contact_phone_no",                                        null: false
    t.string   "slot_option_0",                                           null: false
    t.string   "slot_option_1"
    t.string   "slot_option_2"
    t.string   "slot_granted"
    t.string   "processing_state",                  default: "requested", null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "override_delivery_error",           default: false
    t.string   "delivery_error_type"
    t.string   "reference_no"
    t.boolean  "closed"
    t.uuid     "prisoner_id",                                             null: false
    t.string   "locale",                  limit: 2,                       null: false
  end

  add_index "visits", ["prison_id"], name: "index_visits_on_prison_id", using: :btree

  add_foreign_key "cancellations", "visits"
  add_foreign_key "prisons", "estates"
  add_foreign_key "rejections", "visits"
  add_foreign_key "users", "estates"
  add_foreign_key "visitors", "visits"
  add_foreign_key "visits", "prisoners"
  add_foreign_key "visits", "prisons"

  create_view :count_visits,  sql_definition: <<-SQL
      SELECT (count(*))::integer AS count
     FROM visits;
  SQL

  create_view :count_visits_by_states,  sql_definition: <<-SQL
      SELECT visits.processing_state,
      (count(*))::integer AS count
     FROM visits
    GROUP BY visits.processing_state;
  SQL

  create_view :count_visits_by_prison_and_states,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name;
  SQL

  create_view :count_visits_by_prison_and_calendar_weeks,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      (date_part('isoyear'::text, visits.created_at))::integer AS year,
      (date_part('week'::text, visits.created_at))::integer AS week,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name, (date_part('week'::text, visits.created_at))::integer, (date_part('isoyear'::text, visits.created_at))::integer;
  SQL

  create_view :count_visits_by_prison_and_calendar_dates,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      (date_part('year'::text, visits.created_at))::integer AS year,
      (date_part('month'::text, visits.created_at))::integer AS month,
      (date_part('day'::text, visits.created_at))::integer AS day,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name, (date_part('day'::text, visits.created_at))::integer, (date_part('month'::text, visits.created_at))::integer, (date_part('year'::text, visits.created_at))::integer;
  SQL

  create_view :distributions,  sql_definition: <<-SQL
      SELECT percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY date_part('epoch'::text, (vsc.created_at - v.created_at))) AS percentiles
     FROM (visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))));
  SQL

  create_view :distribution_by_prisons,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY (round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer) AS percentiles
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name;
  SQL

  create_view :distribution_by_prison_and_calendar_weeks,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY (round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer) AS percentiles,
      (date_part('isoyear'::text, v.created_at))::integer AS year,
      (date_part('week'::text, v.created_at))::integer AS week
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name, (date_part('week'::text, v.created_at))::integer, (date_part('isoyear'::text, v.created_at))::integer;
  SQL

  create_view :distribution_by_prison_and_calendar_dates,  sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY (round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer) AS percentiles,
      (date_part('year'::text, v.created_at))::integer AS year,
      (date_part('month'::text, v.created_at))::integer AS month,
      (date_part('day'::text, v.created_at))::integer AS day
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name, (date_part('day'::text, v.created_at))::integer, (date_part('month'::text, v.created_at))::integer, (date_part('year'::text, v.created_at))::integer;
  SQL

  create_view :count_overdue_visits,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state
     FROM (visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY vsc.visit_state
  UNION
   SELECT count(*) AS count,
      v.processing_state AS visit_state
     FROM visits v
    WHERE ((date_part('epoch'::text, v.created_at) > (259200)::double precision) AND (( SELECT count(*) AS count
             FROM visit_state_changes
            WHERE (v.id = visit_state_changes.visit_id)) = 0))
    GROUP BY v.processing_state;
  SQL

  create_view :count_overdue_visits_by_prisons,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY prisons.name, vsc.visit_state
  UNION
   SELECT count(*) AS count,
      v.processing_state AS visit_state,
      prisons.name AS prison_name
     FROM (visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
    WHERE ((date_part('epoch'::text, v.created_at) > (259200)::double precision) AND (( SELECT count(*) AS count
             FROM visit_state_changes
            WHERE (v.id = visit_state_changes.visit_id)) = 0))
    GROUP BY prisons.name, v.processing_state;
  SQL

  create_view :count_overdue_visits_by_prison_and_calendar_weeks,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('week'::text, v.created_at))::integer AS week,
      (date_part('isoyear'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY vsc.visit_state, prisons.name, (date_part('week'::text, v.created_at))::integer, (date_part('isoyear'::text, v.created_at))::integer
  UNION
   SELECT count(*) AS count,
      v.processing_state AS visit_state,
      prisons.name AS prison_name,
      (date_part('week'::text, v.created_at))::integer AS week,
      (date_part('isoyear'::text, v.created_at))::integer AS year
     FROM (visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
    WHERE ((date_part('epoch'::text, v.created_at) > (259200)::double precision) AND (( SELECT count(*) AS count
             FROM visit_state_changes
            WHERE (v.id = visit_state_changes.visit_id)) = 0))
    GROUP BY v.processing_state, prisons.name, (date_part('week'::text, v.created_at))::integer, (date_part('isoyear'::text, v.created_at))::integer;
  SQL

  create_view :count_overdue_visits_by_prison_and_calendar_dates,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('day'::text, v.created_at))::integer AS day,
      (date_part('month'::text, v.created_at))::integer AS month,
      (date_part('year'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY vsc.visit_state, prisons.name, (date_part('day'::text, v.created_at))::integer, (date_part('month'::text, v.created_at))::integer, (date_part('year'::text, v.created_at))::integer
  UNION
   SELECT count(*) AS count,
      v.processing_state AS visit_state,
      prisons.name AS prison_name,
      (date_part('day'::text, v.created_at))::integer AS day,
      (date_part('month'::text, v.created_at))::integer AS month,
      (date_part('year'::text, v.created_at))::integer AS year
     FROM (visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
    WHERE ((date_part('epoch'::text, v.created_at) > (259200)::double precision) AND (( SELECT count(*) AS count
             FROM visit_state_changes
            WHERE (v.id = visit_state_changes.visit_id)) = 0))
    GROUP BY v.processing_state, prisons.name, (date_part('day'::text, v.created_at))::integer, (date_part('month'::text, v.created_at))::integer, (date_part('year'::text, v.created_at))::integer;
  SQL

  create_view :timely_and_overdue_by_calendar_weeks,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      'overdue'::text AS status,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('week'::text, v.created_at))::integer AS week,
      (date_part('isoyear'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text <> 'requested'::text))))
    WHERE ((date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision) AND ((vsc.visit_state)::text = (v.processing_state)::text))
    GROUP BY prisons.name, vsc.visit_state, (date_part('week'::text, v.created_at))::integer, (date_part('isoyear'::text, v.created_at))::integer
  UNION
   SELECT count(*) AS count,
      'timely'::text AS status,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('week'::text, v.created_at))::integer AS week,
      (date_part('isoyear'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text <> 'requested'::text))))
    WHERE ((date_part('epoch'::text, (vsc.created_at - v.created_at)) < (259200)::double precision) AND ((vsc.visit_state)::text = (v.processing_state)::text))
    GROUP BY prisons.name, vsc.visit_state, (date_part('week'::text, v.created_at))::integer, (date_part('isoyear'::text, v.created_at))::integer;
  SQL

  create_view :timely_and_overdues,  sql_definition: <<-SQL
      SELECT count(*) AS count,
      'overdue'::text AS status,
      vsc.visit_state,
      prisons.name AS prison_name
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text <> 'requested'::text))))
    WHERE ((date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision) AND ((vsc.visit_state)::text = (v.processing_state)::text))
    GROUP BY prisons.name, vsc.visit_state
  UNION
   SELECT count(*) AS count,
      'timely'::text AS status,
      vsc.visit_state,
      prisons.name AS prison_name
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text <> 'requested'::text))))
    WHERE ((date_part('epoch'::text, (vsc.created_at - v.created_at)) < (259200)::double precision) AND ((vsc.visit_state)::text = (v.processing_state)::text))
    GROUP BY prisons.name, vsc.visit_state;
  SQL

end
