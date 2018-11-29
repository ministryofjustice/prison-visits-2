module Nomis
  class Feature
    def self.slot_availability_enabled?(prison_name)
      Nomis::Api.enabled? && config.nomis_staff_slot_availability_enabled &&
        config.staff_prisons_with_slot_availability.include?(prison_name)
    end

    def self.config
      Rails.configuration
    end
  end
end
