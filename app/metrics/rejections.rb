# frozen_string_literal: true
require 'support/counter_support'

module Rejections
  class RejectionPercentageByPrison < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      query.map { |q| [q.prison_name, q.reason, q.percentage] }
    end

    def self.query
      find_by_sql <<-SQL
WITH rejection_reasons AS (
  SELECT visit_id, unnest(reasons) AS reason
  FROM rejections
  GROUP BY visit_id, reasons
)

SELECT rejected.prison_name,
       'total' AS reason,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage
FROM (

        SELECT prisons.name AS prison_name,
               count(*) AS rejected_count
        FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        INNER JOIN rejections ON rejections.visit_id = visits.id
        WHERE visits.processing_state = 'rejected'
        GROUP BY prison_name, prison_id

     ) rejected,

     (

        SELECT prisons.name AS prison_name,
               count(*) AS total_count
        FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        GROUP BY prison_name,
                 prison_id

      ) booked

WHERE rejected.prison_name = booked.prison_name
GROUP BY rejected.prison_name,
         percentage
UNION
SELECT rejected.prison_name,
       reason,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage
FROM (

        SELECT reason,
               prisons.name AS prison_name,
               count(*) AS rejected_count
        FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        INNER JOIN rejection_reasons ON visits.id = rejection_reasons.visit_id
        WHERE visits.processing_state = 'rejected'
        GROUP BY prison_name, prison_id, reason

     ) rejected,
     (

        SELECT prisons.name AS prison_name,
               count(*)     AS total_count
        FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        GROUP BY prison_name,
                 prison_id

     ) booked
WHERE rejected.prison_name = booked.prison_name
GROUP BY rejected.prison_name,
         reason,
         percentage
      SQL
    end
  end

  class RejectionPercentageByPrisonAndCalendarWeek < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      query.map { |q| [q.prison_name, q.year, q.week, q.reason, q.percentage] }
    end

    def self.query
      find_by_sql <<-SQL

WITH rejection_reasons AS (
  SELECT visit_id, unnest(reasons) AS reason
  FROM rejections
  GROUP BY visit_id, reasons
)

SELECT rejected.prison_name,
       'total' AS reason,
       rejected.year AS year,
       rejected.week AS week,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage
FROM (SELECT prisons.name AS prison_name,
             count(*) AS rejected_count,
             extract(isoyear from visits.created_at)::integer AS year,
             extract(week from visits.created_at)::integer AS week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
             prison_id,
             year,
             week
      ) rejected,
     (SELECT prisons.name AS prison_name,
             count(*) AS total_count,
             extract(isoyear from visits.created_at)::integer AS total_year,
             extract(week from visits.created_at)::integer AS total_week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      GROUP BY prison_name,
               prison_id,
               total_year,
               total_week
      ) total
WHERE rejected.prison_name = total.prison_name
AND year = total_year
AND week = total_week
GROUP BY rejected.prison_name,
         reason,
         percentage,
         year,
         week
UNION
SELECT rejected.prison_name,
       reason,
       rejected.year AS year,
       rejected.week AS week,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage
FROM (SELECT reason,
             prisons.name AS prison_name,
             count(*) AS rejected_count,
             extract(isoyear from visits.created_at)::integer AS year,
             extract(week from visits.created_at)::integer AS week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejection_reasons ON visits.id = rejection_reasons.visit_id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
             prison_id,
               reason,
               year,
               week
      ) rejected,
     (SELECT prisons.name AS prison_name,
             count(*) AS total_count,
             extract(isoyear from visits.created_at)::integer AS total_year,
             extract(week from visits.created_at)::integer AS total_week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      GROUP BY prison_name,
               prison_id,
               total_year,
               total_week
      ) total
WHERE rejected.prison_name = total.prison_name
AND year = total_year
AND week = total_week
GROUP BY rejected.prison_name,
         reason,
         percentage,
         year,
         week
      SQL
    end
  end
end
