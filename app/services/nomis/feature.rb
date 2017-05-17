module Nomis
  class Feature
    def self.contact_list_enabled?(visit)
      prisoner_check_enabled? &&
        Rails.
        configuration.
        staff_prisons_with_nomis_contact_list.include?(visit.prison_name)
    end

    def self.prisoner_check_enabled?
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_prisoner_check_enabled
    end

    def self.prisoner_availability_enabled?
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_prisoner_availability_enabled
    end

    def self.slot_availability_enabled?(visit)
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_slot_availability_enabled &&
        Rails.
        configuration.
        staff_prisons_with_slot_availability.include?(visit.prison_name)
    end
  end
end
