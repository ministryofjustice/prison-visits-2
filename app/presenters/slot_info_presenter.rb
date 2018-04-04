class SlotInfoPresenter

  def initialize(prison)
    self.prison = prison
  end

  def slots_for(day)
    slot_details = prison.slot_details['recurring'][day]

    slot_details&.any? ? slot_details : []
  end

private
  attr_accessor :prison
end
