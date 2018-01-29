module Nomis
  class PrisonerDetailedAvailability
    include MemoryModel

    attribute :dates, :prisoner_date_availability_list

    def self.build(attrs)
      new_attrs = attrs.each_with_object(dates: []) do |(date, info), list|
        availability = info.deep_dup
        availability['date'] = date
        list[:dates] << availability
      end

      new(new_attrs)
    end

    def available?(slot)
      error_messages_for_slot(slot).empty?
    end

    def error_messages_for_slot(slot)
      availability_for(slot).unavailable_reasons(slot)
    end

  private

    def availability_for(slot)
      dates.find do |date_availability|
        date_availability.date == slot.to_date
      end
    end
  end
end
