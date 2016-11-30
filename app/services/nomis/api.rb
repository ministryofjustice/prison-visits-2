module Nomis
  Error = Class.new(StandardError)
  DisabledError = Class.new(Error)
  NotFound = Class.new(Error)

  class Api
    class << self
      def enabled?
        Rails.configuration.nomis_api_host != nil
      end

      def instance
        unless enabled?
          fail DisabledError, 'Nomis API is disabled'
        end

        @instance ||= begin
          host = Rails.configuration.nomis_api_host
          client_token = Rails.configuration.nomis_api_token
          client_key = Rails.configuration.nomis_api_key
          client = Nomis::Client.new(host, client_token, client_key)
          new(client)
        end
      end
    end

    def initialize(client)
      @client = client
    end

    def lookup_active_offender(noms_id:, date_of_birth:)
      response = @client.get(
        '/lookup/active_offender',
        noms_id: noms_id,
        date_of_birth: date_of_birth
      )

      build_offender(response)
    rescue APIError => e
      Raven.capture_exception(e)
      NullOffender.new(api_call_successful: false)
    end

    def offender_visiting_availability(offender_id:, start_date:, end_date:)
      response = @client.get(
        "/offenders/#{offender_id}/visiting_availability",
        offender_id: offender_id,
        start_date:  start_date,
        end_date:    end_date
      )

      PrisonerAvailability.new(response)
    end

    def fetch_bookable_slots(prison:, start_date:, end_date:)
      response = @client.get(
        "/prison/#{prison.nomis_id}/free_slots",
        start_date: start_date,
        end_date: end_date
      )
      response['slots'].map { |s| ConcreteSlot.parse(s) }
    end

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
