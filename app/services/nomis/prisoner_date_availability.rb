module Nomis
  class PrisonerDateAvailability
    include MemoryModel

    BOOKED_VISIT = 'booked_visit'.freeze
    EXTERNAL_MOVEMENT = 'external_movement'.freeze
    OUT_OF_VO = 'out_of_vo'.freeze

    attribute :date, :date
    attribute :banned, :boolean
    attribute :out_of_vo, :boolean
    attribute :external_movement, :boolean
    attribute :existing_visits, :availability_visit_list, default: []

    def available?(requested_slot)
      unavailable_reasons(requested_slot).empty?
    end

    def unavailable_reasons(requested_slot)
      reasons = []
      reasons << EXTERNAL_MOVEMENT if external_movement
      reasons << OUT_OF_VO if out_of_vo
      reasons << BOOKED_VISIT if booked_visit?(requested_slot)
      reasons
    end

  private

    def booked_visit?(requested_slot)
      existing_visits.any? { |visit| visit.slot.overlaps?(requested_slot) }
    end
  end
end
