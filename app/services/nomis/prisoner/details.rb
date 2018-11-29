module Nomis
  class Prisoner
    class Details
      include MemoryModel

      attribute :aliases
      attribute :api_call_successful, :boolean, default: true
      attribute :convicted, :boolean
      attribute :cro_number, :string
      attribute :csra
      attribute :date_of_birth, :date
      attribute :diet
      attribute :ethnicity
      attribute :gender
      attribute :given_name, :string
      attribute :iep_level
      attribute :imprisonment_status
      attribute :language
      attribute :middle_names, :string
      attribute :nationalities, :string
      attribute :pnc_number, :string
      attribute :religion
      attribute :suffix
      attribute :surname, :string
      attribute :title, :string
      attribute :security_category

      def valid?
        api_call_successful
      end
    end
  end
end
