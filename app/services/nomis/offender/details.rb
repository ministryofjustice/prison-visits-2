module Nomis
  class Offender
    class Details
      include NonPersistedModel

      attribute :given_name,          String
      attribute :surname,             String
      attribute :date_of_birth,       MaybeDate
      attribute :aliases,             Array[String]
      attribute :gender,              Hash[Symbol => String]
      attribute :convicted,           Boolean
      attribute :imprisonment_status, Hash[Symbol => String]
      attribute :iep_level,           Hash[Symbol => String]

      attribute :api_call_successful, Boolean, default: true

      def valid?
        @api_call_successful
      end
    end
  end
end
