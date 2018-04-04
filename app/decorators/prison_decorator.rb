class PrisonDecorator < Draper::Decorator
  delegate_all

  def recurring_slot_list_for(day)
    slots_info = SlotInfoDecorator.decorate_collection(slot_info_presenter.slots_for(day))
    if slots_info.any?
      h.render slots_info
    else
      h.render 'staff_info/no_visits'
    end
  end

private

  def slot_info_presenter
    @slot_info_presenter ||= SlotInfoPresenter.new(object)
  end
end
