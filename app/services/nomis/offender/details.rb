module Nomis
  class Offender
    class Details
      include MemoryModel

      attribute :given_name, :string
      attribute :surname, :string
      attribute :title, :string
      attribute :date_of_birth, :date
      attribute :aliases
      attribute :gender
      attribute :convicted, :boolean
      attribute :imprisonment_status
      attribute :iep_level
      attribute :api_call_successful, :boolean, default: true

      def valid?
        api_call_successful
      end
    end
  end
end
