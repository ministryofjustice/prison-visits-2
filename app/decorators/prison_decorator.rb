class PrisonDecorator < Draper::Decorator
  delegate_all

  def recurring_slot_list_for(day)
    slots_info = SlotInfoPresenter
                   .slots_for(object, day)
                   .map{ |slot| h.colon_formatted_slot(slot) }

    if slots_info.any?
      h.render collection: slots_info, partial: 'staff_info/slot_list_item'
    else
      h.render 'staff_info/no_visits'
    end
  end
end
