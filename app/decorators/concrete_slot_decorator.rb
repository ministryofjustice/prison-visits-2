class ConcreteSlotDecorator < Draper::Decorator
  delegate_all
  RADIO_BUTTON_OPTIONS = {
    class: 'js-Conditional',
    data: {
      'conditional-el' => 'selected_slot_details',
      'conditional-val' => 'slot_option_0,slot_option_1,slot_option2'
    }.freeze
  }.freeze

  # rubocop:disable Metrics/MethodLength
  def slot_picker(form_builder)
    h.concat(
      h.content_tag(
        :div,
        class: 'date-box'
      ){
        h.concat(
          h.content_tag(
            :div,
            class: 'multiple-choice'
          ){
            h.concat(
              form_builder.radio_button(
                :slot_granted,
                iso8601,
                radio_options
              )
            )
            h.concat(
              form_builder.label(
                :slot_granted,
                class: label_classes,
                value: iso8601,
                data: { target: 'selected_slot_details' }
              ) {
                h.concat(label_text)
              }
            )
          }
        )
      }
    )

    if prisoner_available?
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            '.prisoner_available',
            scope: %w[prison visits requested]
          ),
          class: 'date-box__message font-xsmall tag tag--verified'
        )
      )
    end

    if slot_available?
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            '.slot_available',
            scope: %w[prison visits requested]
          ),
          class: 'date-box__message font-xsmall tag tag--verified'
        )
      )
    end

    errors.each do |error|
      h.concat(
        h.content_tag(
          :span,
          I18n.t(
            ".#{error}",
            scope: %w[prison visits requested]
          ),
          class: 'date-box__message font-xsmall tag tag--error'
        )
      )
    end

    nil
  end
  # rubocop:enable Metrics/MethodLength

  def bookable?
    prisoner_available? && slot_available?
  end

private

  def prisoner_available?
    object.to_date.future? &&
      !nomis_checker.prisoner_availability_unknown? &&
      errors.none? do |e|
        PrisonerAvailabilityValidation::PRISONER_ERRORS.include?(e)
      end
  end

  def slot_available?
    object.to_date.future? &&
      Nomis::Feature.slot_availability_enabled?(visit.prison_name) &&
      !nomis_checker.slot_availability_unknown? &&
      errors.none? { |e| e == SlotAvailabilityValidation::SLOT_NOT_AVAILABLE }
  end

  def radio_options
    options = RADIO_BUTTON_OPTIONS.deep_dup
    options[:disabled] = 'disabled' if slot_in_past?
    options[:class] << ' js-closedRestriction' if closed_restriction?
    options
  end

  def slot_in_past?
    !object.to_date.future?
  end

  def label_text
    @label_text ||= I18n.t(
      '.choice_html', options_for_label_key).html_safe
  end

  def label_classes
    classes = 'date-box__label'

    if errors.any?
      classes << ' date-box--error'
    end

    if slot_in_past?
      classes << ' disabled'
    end

    classes
  end

  def options_for_label_key
    {
      day: h.format_date_day(object),
      date: h.format_date(object),
      time: h.format_slot_times(object),
      scope: %w[prison visits visit_date_section]
    }
  end

  def errors
    @errors ||= nomis_checker.errors_for(object)
  end

  def closed_restriction?
    errors.any? { |e| e == Nomis::Restriction::CLOSED_NAME }
  end

  def nomis_checker
    h.nomis_checker
  end

  def visit
    context[:visit]
  end
end
