# frozen_string_literal: true

class SlotInfoPresenter
  def self.slots_for(prison, day)
    slot_details = prison.slot_details['recurring'][day]

    slot_details&.any? ? slot_details : []
  end
end
