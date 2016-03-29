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
  end
end
