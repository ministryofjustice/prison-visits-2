module Nomis
  class Feature
    def self.contact_list_enabled?(prison_name)
      prisoner_check_enabled? &&
        Rails.
        configuration.
        staff_prisons_without_nomis_contact_list.exclude?(prison_name)
    end

    def self.prisoner_check_enabled?
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_prisoner_check_enabled
    end

    def self.prisoner_availability_enabled?
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_prisoner_availability_enabled
    end

    def self.slot_availability_enabled?(prison_name)
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_slot_availability_enabled &&
        Rails.
        configuration.
        staff_prisons_with_slot_availability.include?(prison_name)
    end

    def self.book_to_nomis_enabled?(prison_name)
      Nomis::Api.enabled? &&
        Rails.configuration.nomis_staff_book_to_nomis_enabled &&
        Rails.
        configuration.
        staff_prisons_with_book_to_nomis.include?(prison_name)
    end

    def self.offender_restrictions_enabled?
      prisoner_check_enabled? &&
        Rails.configuration.nomis_staff_offender_restrictions_enabled
    end
  end
end
