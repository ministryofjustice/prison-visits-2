require 'nomis/client'

module Nomis
  class Api
    include Singleton
    BOOK_VISIT_TIMEOUT = 3
    def self.enabled?
      Rails.configuration.nomis_api_host != nil
    end

    def initialize
      unless self.class.enabled?
        fail Nomis::Error::Disabled, 'Nomis API is disabled'
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
      PVB::ExceptionHandler.capture_exception(e, fingerprint: %w[nomis api_error])
      NullOffender.new(api_call_successful: false)
    end
    # rubocop:enable Metrics/MethodLength

    def lookup_offender_details(noms_id:)
      response = @pool.with { |client| client.get("/offenders/#{noms_id}") }
      api_serialiser.
        serialise(Nomis::Offender::Details, response).tap do |offender_details|
        PVB::Instrumentation.append_to_log(
          valid_offender_details_lookup: offender_details.valid?
        )
      end
    end

    def lookup_offender_location(noms_id:)
      response = @pool.with { |client|
        client.get("/offenders/#{noms_id}/location")
      }

      Nomis::Establishment.build(response).tap do |establishment|
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
          offender_visiting_availability: prisoner_availability.dates.count
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
          slot_visiting_availability: slot_availability.slots.count)
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
          options: book_visit_request_options
        )
      }

      Nomis::Booking.build(response).tap do |booking|
        PVB::Instrumentation.append_to_log(
          book_to_nomis_success: booking.visit_id.present?
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def cancel_visit(offender_id, booking_id, params:)
      response = @pool.with { |client|
        client.patch(
          "offenders/#{offender_id}/visits/booking/#{booking_id}/cancel", params)
      }
      Nomis::Cancellation.new(response).tap do |cancellation|
        PVB::Instrumentation.append_to_log(
          cancel_to_nomis_success: cancellation.error_message.nil?)
      end
    end

  private

    def build_offender(response)
      if response['found'] == true
        api_serialiser.serialise(Offender, response['offender'])
      else
        NullOffender.new(api_call_successful: true)
      end
    end

    def book_visit_request_options
      {
        connect_timeout: Nomis::Api::BOOK_VISIT_TIMEOUT,
        read_timeout:    Nomis::Api::BOOK_VISIT_TIMEOUT,
        write_timeout:   Nomis::Api::BOOK_VISIT_TIMEOUT
      }
    end

    def api_serialiser
      @api_serialiser ||= ApiSerialiser.new
    end
  end
end
