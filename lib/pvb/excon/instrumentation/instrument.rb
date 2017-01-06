module PVB
  module Excon
    module Instrumentation
      module Instrument

        def initialize(start, finish, payload)
          self.start   = start
          self.finish  = finish
          self.payload = payload
        end

        private
        attr_accessor :start, :finish, :payload

      end
    end
  end
end

require 'pvb/excon/instrumentation/request'
require 'pvb/excon/instrumentation/response'
require 'pvb/excon/instrumentation/error'
