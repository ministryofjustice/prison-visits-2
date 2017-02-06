module PVB
  module Excon
    module Instrument
      def initialize(start, finish, payload)
        self.start   = start
        self.finish  = finish
        self.payload = payload
      end

    private

      attr_accessor :start, :finish, :payload

      def api_call_error
        "#{RequestStore.store[:nomis_api_name]}_error"
      end
    end
  end
end

require 'pvb/excon/instrument/request'
require 'pvb/excon/instrument/retry'
require 'pvb/excon/instrument/response'
require 'pvb/excon/instrument/error'
