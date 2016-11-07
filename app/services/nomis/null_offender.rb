require 'nomis/offender'

module Nomis
  class NullOffender < Offender
    def valid?
      false
    end
  end
end
