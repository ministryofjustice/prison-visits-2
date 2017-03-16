class ConcreteSlotDecorator < Draper::Decorator
  delegate_all
  RADIO_BUTTON_OPTIONS = {
    class: 'js-Conditional',
    data: {
      'conditional-el'  => 'selected_slot_details',
      'conditional-val' => 'slot_option_0,slot_option_1,slot_option2'
    }
  }.freeze

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def slot_picker(form_builder)
    html_classes = 'block-label date-box'

    if errors.any?
      html_classes << ' date-box--error'
    end
    h.concat(
      form_builder.label(
        :slot_granted,
        class: html_classes,
        value: iso8601,
        data: { target: 'selected_slot_details' }
      ) do
        h.concat(
          form_builder.radio_button(
            :slot_granted,
            iso8601,
            RADIO_BUTTON_OPTIONS)
        )
        h.concat(label_text)
      end
    )

    if prisoner_available?
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            '.prisoner_available',
            scope: %w[prison visits process_visit]
          ),
          class: 'date-box__message bold-xsmall tag tag--verified'
        )
      )
    end

    if slot_available?
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            '.slot_available',
            scope: %w[prison visits process_visit]
          ),
          class: 'date-box__message bold-xsmall tag tag--verified'
        )
      )
    end

    errors.each do |error|
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            ".#{error}",
            scope: %w[prison visits process_visit]
          ),
          class: 'date-box__message bold-xsmall tag tag--error'
        )
      )
    end
    nil

  end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

private

  def prisoner_available?
    object.to_date.future? &&
    nomis_checker.prisoner_availability_enabled? &&
      !nomis_checker.prisoner_availability_unknown? &&
      errors.none? do |e|
        PrisonerAvailabilityValidation::PRISONER_ERRORS.include?(e)
      end
  end

  def slot_available?
    object.to_date.future? &&
    nomis_checker.slot_availability_enabled? &&
      !nomis_checker.slot_availability_unknown? &&
      errors.none? { |e| e == SlotAvailabilityValidation::SLOT_NOT_AVAILABLE }
  end

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
