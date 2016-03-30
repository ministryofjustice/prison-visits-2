module Nomis
  DisabledError = Class.new(StandardError)

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
          client = Nomis::Client.new(Rails.configuration.nomis_api_host)
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
      return nil unless response['found'] == true
      Offender.new(response['offender'])
    end

    # rubocop:disable Metrics/MethodLength
    def offender_visiting_availability(offender_id:, start_date:, end_date:)
      response = @client.get(
        "/offenders/#{offender_id}/visiting_availability",
        offender_id: offender_id,
        start_date: start_date,
        end_date: end_date
      )
      if response.fetch('available')
        dates = response.fetch('dates').map(&:to_date)
        return PrisonerAvailability.new(dates: dates)
      else
        return PrisonerAvailability.new(dates: [])
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
