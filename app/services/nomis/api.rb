module Nomis
  class Api
    class << self
      def instance
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
      return nil unless response['found'] == 'true'
      Offender.new(id: response['offender_id'])
    end
  end
end
