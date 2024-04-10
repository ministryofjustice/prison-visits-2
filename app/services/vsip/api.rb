module Vsip
  class Api
    include Singleton
    BOOK_VISIT_TIMEOUT = 3
    def self.enabled?
      Rails.configuration.vsip_host != nil
    end

    def initialize
      unless self.class.enabled?
        fail Vsip::Error::Disabled, 'Vsip API is disabled'
      end

      pool_size = Rails.configuration.connection_pool_size
      @pool = ConnectionPool.new(size: pool_size, timeout: 5) do
        Vsip::Client.new(Rails.configuration.vsip_host)
      end
    end

    def supported_prisons
      response = @pool.with { |client|
        client.get('config/prisons/supported')
      }

      mark_vsip_prisons response
    rescue APIError => e
      PVB::ExceptionHandler.capture_exception(e, fingerprint: %w[vsip api_error])
    end

  private

    def mark_vsip_prisons prison_list
      mark_all_estates_as_not_vsip
      prison_list.each do |prison_id|
        Estate.where(nomis_id: prison_id).update(vsip_supported: true)
      end
    end

    def mark_all_estates_as_not_vsip
      Estate.all.update(vsip_supported: false)
    end
  end
end
