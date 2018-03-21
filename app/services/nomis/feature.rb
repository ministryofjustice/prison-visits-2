module Nomis
  class Feature
    def self.slot_availability_enabled?(prison_name)
      Nomis::Api.enabled? && config.nomis_staff_slot_availability_enabled &&
        config.staff_prisons_with_slot_availability.include?(prison_name)
    end

    def self.book_to_nomis_enabled?(prison_name)
      Nomis::Api.enabled? && config.nomis_staff_book_to_nomis_enabled &&
        config.staff_prisons_with_book_to_nomis.include?(prison_name)
    end

    def self.offender_restrictions_enabled?
      Nomis::Api.enabled? && config.nomis_staff_offender_restrictions_enabled
    end

    def self.offender_restrictions_info_enabled?(prison_name)
      Nomis::Api.enabled? &&
        offender_restrictions_enabled? &&
        config.staff_prisons_with_prisoner_restrictions_info&.include?(prison_name)
    end

    def self.config
      Rails.configuration
    end
  end
end
