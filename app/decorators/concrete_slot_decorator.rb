class ConcreteSlotDecorator < Draper::Decorator
  delegate_all

  def label_for(form_builder, index, nomis_checker)
    html_classes = 'block-label date-box'
    nomis_checker.errors_for(object)
    form_builder.label :slot_granted, class: html_classes, value: iso8601 do
      form_builder.radio_button :slot_granted, iso8601, class: 'js-Conditional', data: { 'conditional-el': 'selected_slot_details', 'conditional-val': 'slot_option_0,slot_option_1,slot_option2'}
      label(index+1)
    end
  end

  private

  def label(index)
    @label_key ||= I18n.t(
      '.choice_html', options_for_label_key(index)).html_safe
  end

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
