module Nomis
  class Feature
    def self.slot_availability_enabled?(prison_name)
      Nomis::Api.enabled? && config.nomis_staff_slot_availability_enabled &&
        config.staff_prisons_with_slot_availability.include?(prison_name)
    end

    def self.restrictions_enabled?
      Nomis::Api.enabled? && config.nomis_staff_restrictions_enabled
    end

    def self.restrictions_info_enabled?(prison_name)
      Nomis::Api.enabled? &&
        restrictions_enabled? &&
        config.staff_prisons_with_restrictions_info&.include?(prison_name)
    end

    def self.config
      Rails.configuration
    end
  end
end
