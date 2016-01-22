--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: visit_state_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visit_state_changes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    visit_state character varying,
    visit_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: visits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visits (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    prison_id uuid NOT NULL,
    contact_email_address character varying NOT NULL,
    contact_phone_no character varying NOT NULL,
    slot_option_0 character varying NOT NULL,
    slot_option_1 character varying,
    slot_option_2 character varying,
    slot_granted character varying,
    processing_state character varying DEFAULT 'requested'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    override_delivery_error boolean DEFAULT false,
    delivery_error_type character varying,
    reference_no character varying,
    closed boolean,
    prisoner_id uuid NOT NULL,
    locale character varying(2) NOT NULL
);


--
-- Name: calculate_distributions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW calculate_distributions AS
 SELECT percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY date_part('epoch'::text, (vsc.created_at - v.created_at))) AS percentiles
   FROM (visits v
     JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))));


--
-- Name: prisons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE prisons (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    booking_window integer DEFAULT 28 NOT NULL,
    address text,
    email_address character varying,
    phone_no character varying,
    slot_details json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lead_days integer DEFAULT 3 NOT NULL,
    weekend_processing boolean DEFAULT false NOT NULL,
    adult_age integer NOT NULL,
    estate_id uuid NOT NULL,
    translations json DEFAULT '{}'::json NOT NULL,
    postcode character varying(8)
);


--
-- Name: calculate_distributions_for_prisons; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW calculate_distributions_for_prisons AS
 SELECT prisons.name AS prison_name,
    percentile_disc((ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])::double precision[]) WITHIN GROUP (ORDER BY (round(date_part('epoch'::text, (vsc.created_at - v.created_at))))::integer) AS percentiles
   FROM ((visits v
     JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
     JOIN prisons ON ((prisons.id = v.prison_id)))
  GROUP BY prisons.name;


--
-- Name: count_visits; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW count_visits AS
 SELECT (count(*))::integer AS count
   FROM visits;


--
-- Name: count_visits_by_prison_and_calendar_dates; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW count_visits_by_prison_and_calendar_dates AS
 SELECT prisons.name AS prison_name,
    (date_part('year'::text, visits.created_at))::integer AS year,
    (date_part('month'::text, visits.created_at))::integer AS month,
    (date_part('day'::text, visits.created_at))::integer AS day,
    visits.processing_state,
    count(*) AS count
   FROM (visits
     JOIN prisons ON ((prisons.id = visits.prison_id)))
  GROUP BY visits.processing_state, prisons.name, (date_part('day'::text, visits.created_at))::integer, (date_part('month'::text, visits.created_at))::integer, (date_part('year'::text, visits.created_at))::integer;


--
-- Name: count_visits_by_prison_and_calendar_weeks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW count_visits_by_prison_and_calendar_weeks AS
 SELECT prisons.name AS prison_name,
    (date_part('isoyear'::text, visits.created_at))::integer AS year,
    (date_part('week'::text, visits.created_at))::integer AS week,
    visits.processing_state,
    count(*) AS count
   FROM (visits
     JOIN prisons ON ((prisons.id = visits.prison_id)))
  GROUP BY visits.processing_state, prisons.name, (date_part('week'::text, visits.created_at))::integer, (date_part('isoyear'::text, visits.created_at))::integer;


--
-- Name: count_visits_by_prison_and_states; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW count_visits_by_prison_and_states AS
 SELECT prisons.name AS prison_name,
    visits.processing_state,
    count(*) AS count
   FROM (visits
     JOIN prisons ON ((prisons.id = visits.prison_id)))
  GROUP BY visits.processing_state, prisons.name;


--
-- Name: count_visits_by_states; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW count_visits_by_states AS
 SELECT visits.processing_state,
    (count(*))::integer AS count
   FROM visits
  GROUP BY visits.processing_state;


--
-- Name: estates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE estates (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nomis_id character varying(3) NOT NULL,
    finder_slug character varying NOT NULL
);


--
-- Name: feedback_submissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feedback_submissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    body text NOT NULL,
    email_address character varying,
    referrer character varying,
    user_agent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: prisoners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE prisoners (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    number character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: visit_state_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visit_state_changes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    visit_state character varying,
    visit_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: processing_times_by_prison_and_state; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW processing_times_by_prison_and_state AS
 SELECT prisons.name AS prison_name,
    vsc.visit_state AS state,
    (percentile_cont((0.95)::double precision) WITHIN GROUP (ORDER BY ((date_part('epoch'::text, (vsc.created_at - v.created_at)))::integer)::double precision))::integer AS ninety_fifth,
    (percentile_cont((0.50)::double precision) WITHIN GROUP (ORDER BY ((date_part('epoch'::text, (vsc.created_at - v.created_at)))::integer)::double precision))::integer AS median
   FROM ((visits v
     JOIN visit_state_changes vsc ON (((v.id = vsc.visit_id) AND ((vsc.visit_state)::text = ANY ((ARRAY['booked'::character varying, 'rejected'::character varying])::text[])))))
     JOIN prisons ON ((prisons.id = v.prison_id)))
  GROUP BY prisons.name, vsc.visit_state;


--
-- Name: rejections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rejections (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    visit_id uuid NOT NULL,
    allowance_renews_on date,
    privileged_allowance_expires_on date,
    reason character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: visitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visitors (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    visit_id uuid NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sort_index integer NOT NULL,
    banned boolean,
    not_on_list boolean
);


--
-- Name: additional_visitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT additional_visitors_pkey PRIMARY KEY (id);


--
-- Name: estates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY estates
    ADD CONSTRAINT estates_pkey PRIMARY KEY (id);


--
-- Name: feedback_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feedback_submissions
    ADD CONSTRAINT feedback_submissions_pkey PRIMARY KEY (id);


--
-- Name: prisoners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prisoners
    ADD CONSTRAINT prisoners_pkey PRIMARY KEY (id);


--
-- Name: prisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prisons
    ADD CONSTRAINT prisons_pkey PRIMARY KEY (id);


--
-- Name: rejections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rejections
    ADD CONSTRAINT rejections_pkey PRIMARY KEY (id);


--
-- Name: visit_state_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visit_state_changes
    ADD CONSTRAINT visit_state_changes_pkey PRIMARY KEY (id);


--
-- Name: visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: index_estates_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_estates_on_name ON estates USING btree (name);


--
-- Name: index_prisons_on_estate_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_prisons_on_estate_id ON prisons USING btree (estate_id);


--
-- Name: index_rejections_on_visit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rejections_on_visit_id ON rejections USING btree (visit_id);


--
-- Name: index_visit_state_changes_on_visit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visit_state_changes_on_visit_id ON visit_state_changes USING btree (visit_id);


--
-- Name: index_visitors_on_visit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visitors_on_visit_id ON visitors USING btree (visit_id);


--
-- Name: index_visitors_on_visit_id_and_sort_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_visitors_on_visit_id_and_sort_index ON visitors USING btree (visit_id, sort_index);


--
-- Name: index_visits_on_prison_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visits_on_prison_id ON visits USING btree (prison_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_1553534323; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rejections
    ADD CONSTRAINT fk_rails_1553534323 FOREIGN KEY (visit_id) REFERENCES visits(id);


--
-- Name: fk_rails_3e8eecd60c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT fk_rails_3e8eecd60c FOREIGN KEY (prisoner_id) REFERENCES prisoners(id);


--
-- Name: fk_rails_4dc5291c8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT fk_rails_4dc5291c8c FOREIGN KEY (visit_id) REFERENCES visits(id);


--
-- Name: fk_rails_6a6069f315; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY prisons
    ADD CONSTRAINT fk_rails_6a6069f315 FOREIGN KEY (estate_id) REFERENCES estates(id);


--
-- Name: fk_rails_b7f24b6847; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT fk_rails_b7f24b6847 FOREIGN KEY (prison_id) REFERENCES prisons(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151021105400');

INSERT INTO schema_migrations (version) VALUES ('20151021105451');

INSERT INTO schema_migrations (version) VALUES ('20151021110523');

INSERT INTO schema_migrations (version) VALUES ('20151021111200');

INSERT INTO schema_migrations (version) VALUES ('20151027171043');

INSERT INTO schema_migrations (version) VALUES ('20151112000000');

INSERT INTO schema_migrations (version) VALUES ('20151112112137');

INSERT INTO schema_migrations (version) VALUES ('20151112112158');

INSERT INTO schema_migrations (version) VALUES ('20151112112210');

INSERT INTO schema_migrations (version) VALUES ('20151113162836');

INSERT INTO schema_migrations (version) VALUES ('20151117102247');

INSERT INTO schema_migrations (version) VALUES ('20151117115424');

INSERT INTO schema_migrations (version) VALUES ('20151117144018');

INSERT INTO schema_migrations (version) VALUES ('20151117160836');

INSERT INTO schema_migrations (version) VALUES ('20151117162316');

INSERT INTO schema_migrations (version) VALUES ('20151118121002');

INSERT INTO schema_migrations (version) VALUES ('20151124095301');

INSERT INTO schema_migrations (version) VALUES ('20151124154246');

INSERT INTO schema_migrations (version) VALUES ('20151125122313');

INSERT INTO schema_migrations (version) VALUES ('20151125144622');

INSERT INTO schema_migrations (version) VALUES ('20151127095415');

INSERT INTO schema_migrations (version) VALUES ('20151127120844');

INSERT INTO schema_migrations (version) VALUES ('20151130084230');

INSERT INTO schema_migrations (version) VALUES ('20151130111628');

INSERT INTO schema_migrations (version) VALUES ('20151202163959');

INSERT INTO schema_migrations (version) VALUES ('20151204142443');

INSERT INTO schema_migrations (version) VALUES ('20151211145100');

INSERT INTO schema_migrations (version) VALUES ('20151214151538');

INSERT INTO schema_migrations (version) VALUES ('20151215105705');

INSERT INTO schema_migrations (version) VALUES ('20151215154514');

INSERT INTO schema_migrations (version) VALUES ('20151222125110');

INSERT INTO schema_migrations (version) VALUES ('20160105112652');

INSERT INTO schema_migrations (version) VALUES ('20160105150712');

INSERT INTO schema_migrations (version) VALUES ('20160106102516');

INSERT INTO schema_migrations (version) VALUES ('20160106165936');

INSERT INTO schema_migrations (version) VALUES ('20160106171414');

INSERT INTO schema_migrations (version) VALUES ('20160112103846');

INSERT INTO schema_migrations (version) VALUES ('20160113104354');

INSERT INTO schema_migrations (version) VALUES ('20160114101538');

INSERT INTO schema_migrations (version) VALUES ('20160115143844');

INSERT INTO schema_migrations (version) VALUES ('20160119172114');

