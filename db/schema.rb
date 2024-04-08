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

ActiveRecord::Schema[7.1].define(version: 2024_04_08_135051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "cancellations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "visit_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "nomis_cancelled", default: false, null: false
    t.string "reasons", default: [], null: false, array: true
    t.index ["visit_id"], name: "index_cancellations_on_visit_id", unique: true
  end

  create_table "estates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "nomis_id", limit: 3, null: false
    t.string "finder_slug", null: false
    t.string "sso_organisation_name"
    t.string "admins", default: [], array: true
    t.boolean "vsip_supported", default: false
    t.index ["name"], name: "index_estates_on_name", unique: true
  end

  create_table "feedback_submissions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "body", null: false
    t.string "email_address"
    t.string "referrer"
    t.string "user_agent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "prison_id"
    t.boolean "submitted_by_staff", default: false, null: false
    t.string "prisoner_number"
    t.date "prisoner_date_of_birth"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.uuid "user_id", null: false
    t.uuid "visit_id", null: false
    t.uuid "visit_state_change_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "nomis_concrete_slots", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "prison_id", null: false
    t.date "date", null: false
    t.integer "start_hour", null: false
    t.integer "start_minute", null: false
    t.integer "end_hour", null: false
    t.integer "end_minute", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["prison_id"], name: "index_nomis_concrete_slots_on_prison_id"
  end

  create_table "prisoners", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.string "number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "nomis_offender_id"
  end

  create_table "prisons", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true, null: false
    t.integer "booking_window", default: 28, null: false
    t.text "address"
    t.string "email_address"
    t.string "phone_no"
    t.json "slot_details", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lead_days", default: 3, null: false
    t.boolean "weekend_processing", default: false, null: false
    t.integer "adult_age", null: false
    t.uuid "estate_id", null: false
    t.json "translations", default: {}, null: false
    t.string "postcode", limit: 8
    t.boolean "closed", default: false, null: false
    t.boolean "private", default: false, null: false
    t.index ["estate_id"], name: "index_prisons_on_estate_id"
  end

  create_table "rejection_percentage_by_prison_and_calendar_weeks", id: :serial, force: :cascade do |t|
  end

  create_table "rejection_percentage_by_prisons", id: :serial, force: :cascade do |t|
  end

  create_table "rejections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "visit_id", null: false
    t.date "allowance_renews_on"
    t.date "privileged_allowance_expires_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "reasons", default: [], array: true
    t.string "rejection_reason_detail"
    t.index ["visit_id"], name: "index_rejections_on_visit_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.uuid "estate_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["estate_id"], name: "index_users_on_estate_id"
  end

  create_table "visit_orders", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "type", default: "VisitOrder", null: false
    t.bigint "number", null: false
    t.string "code", null: false
    t.uuid "visit_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["visit_id"], name: "index_visit_orders_on_visit_id"
  end

  create_table "visit_state_changes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "visit_state"
    t.uuid "visit_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "processed_by_id"
    t.uuid "visitor_id"
    t.string "creator_type"
    t.uuid "creator_id"
    t.index ["creator_type", "creator_id"], name: "index_visit_state_changes_on_creator_type_and_creator_id"
    t.index ["visit_id"], name: "index_visit_state_changes_on_visit_id"
    t.check_constraint "visitor_id IS NULL OR processed_by_id IS NULL", name: "visitor_or_processed_by_set"
  end

  create_table "visitors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "visit_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "sort_index", null: false
    t.boolean "banned", default: false
    t.boolean "not_on_list", default: false
    t.date "banned_until"
    t.integer "nomis_id"
    t.boolean "other_rejection_reason"
    t.index ["visit_id", "sort_index"], name: "index_visitors_on_visit_id_and_sort_index", unique: true
    t.index ["visit_id"], name: "index_visitors_on_visit_id"
  end

  create_table "visits", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "prison_id", null: false
    t.string "contact_email_address", null: false
    t.string "contact_phone_no", null: false
    t.string "slot_option_0", null: false
    t.string "slot_option_1"
    t.string "slot_option_2"
    t.string "slot_granted"
    t.string "processing_state", default: "requested", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "reference_no"
    t.boolean "closed"
    t.uuid "prisoner_id", null: false
    t.string "locale", limit: 2, null: false
    t.string "human_id"
    t.integer "nomis_id"
    t.text "nomis_comments"
    t.index ["human_id"], name: "index_visits_on_human_id", unique: true
    t.index ["prison_id"], name: "index_visits_on_prison_id"
  end

  add_foreign_key "cancellations", "visits"
  add_foreign_key "feedback_submissions", "prisons"
  add_foreign_key "messages", "users"
  add_foreign_key "messages", "visit_state_changes"
  add_foreign_key "messages", "visits"
  add_foreign_key "prisons", "estates"
  add_foreign_key "rejections", "visits"
  add_foreign_key "users", "estates"
  add_foreign_key "visit_orders", "visits"
  add_foreign_key "visit_state_changes", "users", column: "processed_by_id"
  add_foreign_key "visit_state_changes", "visitors"
  add_foreign_key "visitors", "visits"
  add_foreign_key "visits", "prisoners"
  add_foreign_key "visits", "prisons"

  create_view "count_visits", sql_definition: <<-SQL
      SELECT (count(*))::integer AS count
     FROM visits;
  SQL
  create_view "count_visits_by_states", sql_definition: <<-SQL
      SELECT visits.processing_state,
      (count(*))::integer AS count
     FROM visits
    GROUP BY visits.processing_state;
  SQL
  create_view "count_visits_by_prison_and_states", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name;
  SQL
  create_view "count_visits_by_prison_and_calendar_weeks", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      (date_part('isoyear'::text, visits.created_at))::integer AS year,
      (date_part('week'::text, visits.created_at))::integer AS week,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name, ((date_part('week'::text, visits.created_at))::integer), ((date_part('isoyear'::text, visits.created_at))::integer);
  SQL
  create_view "count_visits_by_prison_and_calendar_dates", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      (date_part('year'::text, visits.created_at))::integer AS year,
      (date_part('month'::text, visits.created_at))::integer AS month,
      (date_part('day'::text, visits.created_at))::integer AS day,
      visits.processing_state,
      count(*) AS count
     FROM (visits
       JOIN prisons ON ((prisons.id = visits.prison_id)))
    GROUP BY visits.processing_state, prisons.name, ((date_part('day'::text, visits.created_at))::integer), ((date_part('month'::text, visits.created_at))::integer), ((date_part('year'::text, visits.created_at))::integer);
  SQL
  create_view "count_overdue_visits", sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state
     FROM (visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
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
  create_view "count_overdue_visits_by_prisons", sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
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
  create_view "count_overdue_visits_by_prison_and_calendar_weeks", sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('week'::text, v.created_at))::integer AS week,
      (date_part('isoyear'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY vsc.visit_state, prisons.name, ((date_part('week'::text, v.created_at))::integer), ((date_part('isoyear'::text, v.created_at))::integer)
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
    GROUP BY v.processing_state, prisons.name, ((date_part('week'::text, v.created_at))::integer), ((date_part('isoyear'::text, v.created_at))::integer);
  SQL
  create_view "count_overdue_visits_by_prison_and_calendar_dates", sql_definition: <<-SQL
      SELECT count(*) AS count,
      vsc.visit_state,
      prisons.name AS prison_name,
      (date_part('day'::text, v.created_at))::integer AS day,
      (date_part('month'::text, v.created_at))::integer AS month,
      (date_part('year'::text, v.created_at))::integer AS year
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
    WHERE (date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision)
    GROUP BY vsc.visit_state, prisons.name, ((date_part('day'::text, v.created_at))::integer), ((date_part('month'::text, v.created_at))::integer), ((date_part('year'::text, v.created_at))::integer)
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
    GROUP BY v.processing_state, prisons.name, ((date_part('day'::text, v.created_at))::integer), ((date_part('month'::text, v.created_at))::integer), ((date_part('year'::text, v.created_at))::integer);
  SQL
  create_view "timely_and_overdue_by_calendar_weeks", sql_definition: <<-SQL
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
    GROUP BY prisons.name, vsc.visit_state, ((date_part('week'::text, v.created_at))::integer), ((date_part('isoyear'::text, v.created_at))::integer)
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
    GROUP BY prisons.name, vsc.visit_state, ((date_part('week'::text, v.created_at))::integer), ((date_part('isoyear'::text, v.created_at))::integer);
  SQL
  create_view "visit_counts_by_prison_state_date_and_timely", materialized: true, sql_definition: <<-SQL
      WITH visits_timely AS (
           SELECT prisons.name AS prison_name,
              prisons.id AS prison_id,
              v_1.processing_state,
              v_1.created_at,
                  CASE
                      WHEN ((v_1.processing_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])) THEN ((vsc.created_at - v_1.created_at) < 'P3D'::interval)
                      ELSE NULL::boolean
                  END AS timely
             FROM ((visits v_1
               LEFT JOIN ( SELECT max(visit_state_changes.created_at) AS created_at,
                      visit_state_changes.visit_id
                     FROM visit_state_changes
                    GROUP BY visit_state_changes.visit_id) vsc ON ((vsc.visit_id = v_1.id)))
               LEFT JOIN prisons ON ((prisons.id = v_1.prison_id)))
          )
   SELECT v.prison_name,
      v.prison_id,
      v.processing_state,
      v.timely,
      (v.created_at)::date AS date,
      count(*) AS count
     FROM visits_timely v
    GROUP BY v.prison_name, v.prison_id, v.processing_state, v.timely, ((v.created_at)::date);
  SQL
  create_view "percentiles_by_calendar_dates", materialized: true, sql_definition: <<-SQL
      SELECT (v.created_at)::date AS date,
      percentile_disc(ARRAY[(0.95)::double precision, (0.5)::double precision]) WITHIN GROUP (ORDER BY ((round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer)) AS percentiles
     FROM (visits v
       JOIN ( SELECT max(visit_state_changes.created_at) AS created_at,
              visit_state_changes.visit_id
             FROM visit_state_changes
            GROUP BY visit_state_changes.visit_id) vsc ON ((v.id = vsc.visit_id)))
    WHERE ((v.processing_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text]))
    GROUP BY ((v.created_at)::date);
  SQL
  create_view "rejection_percentage_by_days", materialized: true, sql_definition: <<-SQL
      WITH rejection_reasons AS (
           SELECT rejections.visit_id,
              unnest(rejections.reasons) AS reason
             FROM rejections
            GROUP BY rejections.visit_id, rejections.reasons
          ), rejected_visits_count_by_prison AS (
           SELECT prisons.name AS prison_name,
              prisons.id AS prison_id,
              (visits.created_at)::date AS date,
              count(*) AS rejected_count
             FROM (visits
               JOIN prisons ON ((prisons.id = visits.prison_id)))
            WHERE ((visits.processing_state)::text = 'rejected'::text)
            GROUP BY prisons.name, prisons.id, ((visits.created_at)::date)
          ), visit_count_by_prison AS (
           SELECT prisons.name AS prison_name,
              prisons.id AS prison_id,
              count(*) AS total_count,
              (visits.created_at)::date AS date
             FROM (visits
               JOIN prisons ON ((prisons.id = visits.prison_id)))
            GROUP BY prisons.name, prisons.id, ((visits.created_at)::date)
          ), rejected_visit_count_reason_date_and_prison AS (
           SELECT rejection_reasons.reason,
              prisons.name AS prison_name,
              prisons.id AS prison_id,
              count(*) AS rejected_count,
              (visits.created_at)::date AS date
             FROM ((visits
               JOIN prisons ON ((prisons.id = visits.prison_id)))
               JOIN rejection_reasons ON ((visits.id = rejection_reasons.visit_id)))
            WHERE ((visits.processing_state)::text = 'rejected'::text)
            GROUP BY prisons.name, prisons.id, rejection_reasons.reason, ((visits.created_at)::date)
          ), visit_count_by_prison_and_date AS (
           SELECT prisons.name AS prison_name,
              prisons.id AS prison_id,
              count(*) AS total_count,
              (visits.created_at)::date AS date
             FROM (visits
               JOIN prisons ON ((prisons.id = visits.prison_id)))
            GROUP BY prisons.name, prisons.id, ((visits.created_at)::date)
          )
   SELECT rejected.prison_name,
      rejected.prison_id,
      'total'::text AS reason,
      round((((rejected.rejected_count)::numeric / (total.total_count)::numeric) * (100)::numeric), 2) AS percentage,
      rejected.date
     FROM rejected_visits_count_by_prison rejected,
      visit_count_by_prison total
    WHERE ((rejected.prison_id = total.prison_id) AND (rejected.date = total.date))
    GROUP BY rejected.prison_name, rejected.prison_id, 'total'::text, (round((((rejected.rejected_count)::numeric / (total.total_count)::numeric) * (100)::numeric), 2)), rejected.date
  UNION
   SELECT rejected.prison_name,
      rejected.prison_id,
      rejected.reason,
      round((((rejected.rejected_count)::numeric / (total.total_count)::numeric) * (100)::numeric), 2) AS percentage,
      rejected.date
     FROM rejected_visit_count_reason_date_and_prison rejected,
      visit_count_by_prison_and_date total
    WHERE (((rejected.prison_name)::text = (total.prison_name)::text) AND (rejected.date = total.date))
    GROUP BY rejected.prison_name, rejected.prison_id, rejected.reason, (round((((rejected.rejected_count)::numeric / (total.total_count)::numeric) * (100)::numeric), 2)), rejected.date;
  SQL
  create_view "distributions", sql_definition: <<-SQL
      SELECT percentile_disc(ARRAY[(0.95)::double precision, (0.50)::double precision]) WITHIN GROUP (ORDER BY (date_part('epoch'::text, (vsc.created_at - v.created_at)))) AS percentiles
     FROM (visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))));
  SQL
  create_view "distribution_by_prisons", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc(ARRAY[(0.95)::double precision, (0.50)::double precision]) WITHIN GROUP (ORDER BY ((round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer)) AS percentiles
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name;
  SQL
  create_view "distribution_by_prison_and_calendar_weeks", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc(ARRAY[(0.95)::double precision, (0.50)::double precision]) WITHIN GROUP (ORDER BY ((round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer)) AS percentiles,
      (date_part('isoyear'::text, v.created_at))::integer AS year,
      (date_part('week'::text, v.created_at))::integer AS week
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name, ((date_part('week'::text, v.created_at))::integer), ((date_part('isoyear'::text, v.created_at))::integer);
  SQL
  create_view "distribution_by_prison_and_calendar_dates", sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      percentile_disc(ARRAY[(0.95)::double precision, (0.50)::double precision]) WITHIN GROUP (ORDER BY ((round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer)) AS percentiles,
      (date_part('year'::text, v.created_at))::integer AS year,
      (date_part('month'::text, v.created_at))::integer AS month,
      (date_part('day'::text, v.created_at))::integer AS day
     FROM ((visits v
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text])))))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    GROUP BY prisons.name, ((date_part('day'::text, v.created_at))::integer), ((date_part('month'::text, v.created_at))::integer), ((date_part('year'::text, v.created_at))::integer);
  SQL
  create_view "timely_and_overdues", sql_definition: <<-SQL
      SELECT count(*) AS count,
      'overdue'::text AS status,
      prisons.name AS prison_name
     FROM ((visits v
       JOIN prisons ON ((prisons.id = v.prison_id)))
       JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text <> 'requested'::text))))
    WHERE ((date_part('epoch'::text, (vsc.created_at - v.created_at)) > (259200)::double precision) AND ((vsc.visit_state)::text = (v.processing_state)::text))
    GROUP BY prisons.name;
  SQL
  create_view "percentiles_by_prison_and_calendar_dates", materialized: true, sql_definition: <<-SQL
      SELECT prisons.name AS prison_name,
      prisons.id AS prison_id,
      (timezone('Europe/London'::text, (v.created_at)::timestamp with time zone))::date AS date,
      percentile_disc(ARRAY[(0.95)::double precision, (0.5)::double precision]) WITHIN GROUP (ORDER BY ((round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer)) AS percentiles
     FROM ((visits v
       JOIN ( SELECT max(visit_state_changes.created_at) AS created_at,
              visit_state_changes.visit_id,
              visit_state_changes.visit_state
             FROM visit_state_changes
            GROUP BY visit_state_changes.visit_id, visit_state_changes.visit_state) vsc ON ((v.id = vsc.visit_id)))
       JOIN prisons ON ((prisons.id = v.prison_id)))
    WHERE ((vsc.visit_state)::text = ANY (ARRAY[('booked'::character varying)::text, ('rejected'::character varying)::text]))
    GROUP BY prisons.name, prisons.id, ((timezone('Europe/London'::text, (v.created_at)::timestamp with time zone))::date);
  SQL
end
