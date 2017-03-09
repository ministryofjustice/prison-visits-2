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

    def available?(slot)
      unavailable_reasons(slot).empty?
    end

    def unavailable_reasons(slot)
      reasons = []
      reasons << BANNED if banned
      reasons << EXTERNAL_MOVEMENT if external_movement
      reasons << OUT_OF_VO if out_of_vo
      reasons << BOOKED_VISIT if booked_visit?(slot)
      reasons
    end

  private

    def booked_visit?(slot)
      existing_visits.any? { |visit| visit.slot == slot }
    end
  end
end
