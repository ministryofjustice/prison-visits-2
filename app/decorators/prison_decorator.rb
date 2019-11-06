class PrisonDecorator < Draper::Decorator
  delegate_all

  def slots_for?(day)
    SlotInfoPresenter.slots_for(object, day).any?
  end

  def recurring_slot_list_for(day)
    slots_info = SlotInfoPresenter.
                   slots_for(object, day).
                   map{ |slot| SlotInfoDecorator.decorate(slot) }

    if slots_info.any?
      h.render slots_info
    else
      h.render 'staff_info/no_visits'
    end
  end
end
