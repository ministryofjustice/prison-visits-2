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
          Rails.configuration.nomis_oauth_host)
      end
    end

    # Looks for an active offender with the provided details
    #
    #  noms_id: A nomis number (e.g. A1234AA)
    #  date_of_birth: The offender's date of birth in 8601 format
    #                 ( e.g. 1973-02-21 )
    #
    # returns Nomis::Prisoner | NullPrisoner
    def lookup_active_prisoner(noms_id:, date_of_birth:)
      response = @pool.with { |client|
        client.get('lookup/active_offender',
                   noms_id: noms_id, date_of_birth: date_of_birth)
      }

      build_prisoner(response).tap do |prisoner|
        PVB::Instrumentation.append_to_log(valid_prisoner_lookup: !!response['found'])
        prisoner.noms_id = noms_id
      end
    rescue APIError => e
      PVB::ExceptionHandler.capture_exception(e, fingerprint: %w[nomis api_error])
      NullPrisoner.new(api_call_successful: false)
    end

    # Returns offenders details given a noms_id
    #
    #  noms_id: A nomis number (e.g. A1234AA)
    #
    # returns Nomis::Prisoner::Details
    def lookup_prisoner_details(noms_id:)
      response = @pool.with { |client| client.get("offenders/#{noms_id}") }

      api_serialiser.
        serialise(Nomis::Prisoner::Details, response).tap do |prisoner_details|
        PVB::Instrumentation.append_to_log(
          valid_prisoner_details_lookup: prisoner_details.valid?
        )
      end
    end

    # Obtains the location for a prisoner given their noms id.
    #
    #  noms_id: A nomis number (e.g. A1234AA)
    #
    # returns Nomis::Establishment
    def lookup_prisoner_location(noms_id:)
      response = @pool.with { |client|
        client.get("offenders/#{noms_id}/location")
      }

      Nomis::Establishment.build(response).tap do |establishment|
        PVB::Instrumentation.append_to_log(lookup_prisoner_location: establishment.code)
      end
    end

    # Obtains the visiting availability for a given prisoner
    #
    #  offender_id: The offender's ID which is numeric, this is NOT
    #               their NOMIS number.
    #  start_date: The start date in  8601 format ( e.g. 1973-02-21 )
    #  end_date: The end date in  8601 format ( e.g. 1973-02-21 )
    #
    # TODO: Find out and document the constraints on the start and end date
    #
    # returns PrisonerAvailability
    def prisoner_visiting_availability(offender_id:, start_date:, end_date:)
      response = @pool.with { |client|
        client.get(
          "offenders/#{offender_id}/visits/available_dates",
          start_date: start_date, end_date: end_date)
      }

      PrisonerAvailability.new(response).tap do |prisoner_availability|
        PVB::Instrumentation.append_to_log(
          prisoner_visiting_availability: prisoner_availability.dates.count
        )
      end
    end

    # Obtains the visiting availability for a given prisoner
    #
    #  offender_id: The offender's ID which is numeric, this is NOT
    #               their NOMIS number.
    #  slots: A list of ConcreteSlot instances
    #
    # returns PrisonerDetailedAvailability
    def prisoner_visiting_detailed_availability(offender_id:, slots:)
      response = @pool.with { |client|
        client.get(
          "offenders/#{offender_id}/visits/unavailability",
          dates: slots.map(&:to_date).join(','))
      }

      PrisonerDetailedAvailability.build(response).tap do |availability|
        available_slots = slots.select { |slot| availability.available?(slot) }

        PVB::Instrumentation.append_to_log(
          prisoner_visiting_availability: available_slots.size)
      end
    end

    # Fetches the bookable slots for a prison
    #
    #  prison: An `Estate` instance
    #  start_date: The start date to check from
    #  end_date: The end date to check to
    #
    # TODO: Find out and document the constraints on the start and end date
    #
    # returns Nomis::SlotAvailability
    def fetch_bookable_slots(prison:, start_date:, end_date:)
      response = @pool.with { |client|
        client.get(
          "prison/#{prison.nomis_id}/slots",
          start_date: start_date,
          end_date: end_date)
      }

      Nomis::SlotAvailability.new(response).tap do |slot_availability|
        PVB::Instrumentation.append_to_log(
          slot_visiting_availability: slot_availability.slots.count)
      end
    end

    # Obtains the contact list for an offender
    #
    #  offender_id: The offender's ID which is numeric, this is NOT
    #               their NOMIS number.
    #
    # returns Nomis::ContactList
    def fetch_contact_list(offender_id:)
      response = @pool.with { |client|
        client.get("offenders/#{offender_id}/visits/contact_list")
      }

      Nomis::ContactList.new(response)
    end

  private

    def build_prisoner(response)
      if response['found'] == true
        api_serialiser.serialise(Nomis::Prisoner, response['offender'])
      else
        NullPrisoner.new(api_call_successful: true)
      end
    end

    def api_serialiser
      @api_serialiser ||= ApiSerialiser.new
    end
  end
end
