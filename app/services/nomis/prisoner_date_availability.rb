module Nomis
  class PrisonerDateAvailability
    include NonPersistedModel

    BOOKED_VISIT = 'booked_visit'.freeze
    EXTERNAL_MOVEMENT = 'external_movement'.freeze
    BANNED = 'prisoner_banned'.freeze
    OUT_OF_VO = 'out_of_vo'.freeze

    attribute :date, Date
    attribute :banned, Boolean
    attribute :out_of_vo, Boolean
    attribute :external_movement, Boolean
    attribute :existing_visits, Array[AvailabilityVisit]

    def available?(requested_slot)
      unavailable_reasons(requested_slot).empty?
    end

    def unavailable_reasons(requested_slot)
      reasons = []
      reasons << BANNED if banned
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
