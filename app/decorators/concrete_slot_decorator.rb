class ConcreteSlotDecorator < Draper::Decorator
  delegate_all

  def label(index)
    @label_key ||= I18n.t(
      '.choice_html', options_for_label_key(index)).html_safe
  end

private

  def options_for_label_key(index)
    {
      n:    index,
      day:  h.format_date_day(object),
      date: h.format_date_of_birth(object),
      time: h.format_slot_times(object),
      scope: %w[prison visits visit_date_section]
    }
  end
end
