module PVB
  module Instrumentations
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

require 'pvb/instrumentations/excon/request'
require 'pvb/instrumentations/excon/retry'
require 'pvb/instrumentations/excon/response'
require 'pvb/instrumentations/excon/error'
require 'pvb/instrumentations/faraday/request'
