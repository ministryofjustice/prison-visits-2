require 'nomis/client'

module Nomis
  Error              = Class.new(StandardError)
  DisabledError      = Class.new(Error)
  NotFound           = Class.new(Error)

  class Api
    include Singleton
    BOOK_VISIT_TIMEOUT = 3
    def self.enabled?
      Rails.configuration.nomis_api_host != nil
    end

    def initialize
      unless self.class.enabled?
        fail DisabledError, 'Nomis API is disabled'
      end

      pool_size = Rails.configuration.connection_pool_size
      @pool = ConnectionPool.new(size: pool_size, timeout: 1) do
        Nomis::Client.new(
          Rails.configuration.nomis_api_host,
          Rails.configuration.nomis_api_token,
          Rails.configuration.nomis_api_key)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def lookup_active_offender(noms_id:, date_of_birth:)
      response = @pool.with { |client|
        client.get('/lookup/active_offender',
          noms_id: noms_id, date_of_birth: date_of_birth)
      }

      build_offender(response).tap do |offender|
        PVB::Instrumentation.append_to_log(valid_offender_lookup: !!response['found'])
        offender.noms_id = noms_id
      end
    rescue APIError => e
      Raven.capture_exception(e, fingerprint: %w[nomis api_error])
      NullOffender.new(api_call_successful: false)
    end
    # rubocop:enable Metrics/MethodLength

    def lookup_offender_location(noms_id:)
      response = @pool.with { |client|
        client.get("/offenders/#{noms_id}/location")
      }

      Nomis::Establishment.new(response['establishment']).tap do |establishment|
        PVB::Instrumentation.append_to_log(lookup_offender_location: establishment.code)
      end
    end

    def offender_visiting_availability(offender_id:, start_date:, end_date:)
      response = @pool.with { |client|
        client.get(
          "/offenders/#{offender_id}/visits/available_dates",
          start_date: start_date, end_date: end_date)
      }

      PrisonerAvailability.new(response).tap do |prisoner_availability|
        PVB::Instrumentation.append_to_log(
          offender_visiting_availability: prisoner_availability.dates.size
        )
      end
    end

    def offender_visiting_detailed_availability(offender_id:, slots:)
      response = @pool.with { |client|
        client.get(
          "offenders/#{offender_id}/visits/unavailability",
          dates: slots.map(&:to_date).join(','))
      }

      PrisonerDetailedAvailability.build(response).tap do |availability|
        available_slots = slots.select { |slot| availability.available?(slot) }

        PVB::Instrumentation.append_to_log(
          offender_visiting_availability: available_slots.size)
      end
    end

    def fetch_bookable_slots(prison:, start_date:, end_date:)
      response = @pool.with { |client|
        client.get(
          "/prison/#{prison.nomis_id}/slots",
          start_date: start_date,
          end_date: end_date)
      }

      Nomis::SlotAvailability.new(response).tap do |slot_availability|
        PVB::Instrumentation.append_to_log(
          slot_visiting_availability: slot_availability.slots.size)
      end
    end

    def fetch_offender_restrictions(offender_id:)
      response = @pool.with { |client|
        client.get("offenders/#{offender_id}/visits/restrictions")
      }

      Nomis::OffenderRestrictions.new(response)
    end

    def fetch_contact_list(offender_id:)
      response = @pool.with { |client|
        client.get("offenders/#{offender_id}/visits/contact_list")
      }

      Nomis::ContactList.new(response)
    end

    # rubocop:disable Metrics/MethodLength
    def book_visit(offender_id:, params:)
      idempotent = params.key?(:client_unique_ref)

      response = @pool.with { |client|
        client.post(
          "offenders/#{offender_id}/visits/booking",
          params,
          idempotent: idempotent,
          timeout: Nomis::Api::BOOK_VISIT_TIMEOUT
        )
      }

      Nomis::Booking.build(response).tap do |booking|
        PVB::Instrumentation.append_to_log(
          book_to_nomis_success: booking.visit_id.present?
        )
      end
    end
  # rubocop:enable Metrics/MethodLength

  private

    def build_offender(response)
      if response['found'] == true
        Offender.new(response['offender'])
      else
        NullOffender.new(api_call_successful: true)
      end
    end
  end
end
