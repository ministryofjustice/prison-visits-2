class Healthcheck
  class NomisApiCheck
    include CheckComponent

    def initialize(description)
      build_report(description) do
        { ok: healthy_pvb_connection }
      end
    end

  private

    def healthy_pvb_connection
      client.healthcheck.status == 200
    end

    def client
      Nomis::Client.new(Rails.configuration.prison_api_host)
    end
  end
end
