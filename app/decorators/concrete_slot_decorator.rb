class ConcreteSlotDecorator < Draper::Decorator
  delegate_all
  RADIO_BUTTON_OPTIONS = {
    class: 'js-Conditional',
    data: {
      'conditional-el'  => 'selected_slot_details',
      'conditional-val' => 'slot_option_0,slot_option_1,slot_option2'
    }
  }.freeze

  def label_for(form_builder)
    html_classes = 'block-label date-box'

    html_classes << ' date-box--error' if unavailable?

    form_builder.label(
      :slot_granted, class: html_classes, value: iso8601
    ) do
      form_builder.radio_button(
        :slot_granted, iso8601, RADIO_BUTTON_OPTIONS
      )

      if unavailable?
        h.concat(
          h.content_tag(
            :span,
            I18n.t(
              '.prisoner_unavailable',
              scope: ['prison', 'visits', 'process_visit']
            ),
            class: 'colour--error'
          )
        )
      end

      h.concat(label_text)
    end
  end

  private

  def label_text
    @label_key ||= I18n.t(
      '.choice_html', options_for_label_key).html_safe
  end

  def options_for_label_key
    {
      n:    index + 1,
      day:  h.format_date_day(object),
      date: h.format_date_of_birth(object),
      time: h.format_slot_times(object),
      scope: %w[prison visits visit_date_section]
    }
  end

  def unavailable?
    errors.any?
  end

  def errors
    @errors ||= nomis_checker.errors_for(object)
  end

  def nomis_checker
    context[:nomis_checker]
  end

  def index
    context[:index]
  end
end
