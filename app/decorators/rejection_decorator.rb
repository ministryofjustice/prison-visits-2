class RejectionDecorator < Draper::Decorator
  delegate_all

  RESTRICTON_REASONS = [
    Rejection::PRISONER_NON_ASSOCIATION,
    Rejection::CHILD_PROTECTION_ISSUES,
    Rejection::PRISONER_BANNED,
    Rejection::PRISONER_OUT_OF_PRISON
  ].freeze

  def reasons
    Rejection::ReasonDecorator.decorate(object.reasons)
  end

  def allowance_renews_on
    @allowance_renews_on ||=
      begin
        if object.allowance_renews_on
          AccessibleDate.new(date_to_accessible_date(object.allowance_renews_on))
        else
          AccessibleDate.from_multi_parameters(allowance_renews_on_before_type_cast)
        end
      end
  end

  def checkbox_for(reason, html_options = {}, visit_has_error = false)
    reasons_decorator = Rejection::ReasonDecorator.decorate(object.reasons)
    reasons_decorator.checkbox_for(reason, html_options, visit_has_error)
  end

  def email_formatted_reasons
    email_reasons.each_with_object(Set.new) do |reason, result|
      email_formatted_reason(reason).each do |formatted_reason|
        result << formatted_reason
      end
    end.to_a
  end

  def staff_formatted_reasons
    object.reasons.each_with_object([]) do |reason, result|
      result << case reason
                when 'no_allowance'
                  staff_no_allowance_explanation(object.allowance_renews_on)
                when 'other'
                  staff_other_explanation(object.rejection_reason_detail)
                else
                  h.t(reason, scope: :shared)
                end
    end
  end

  def email_visitor_banned_explanation(visitor)
    if visitor.banned_until?
      h.t('visitor_banned_until_html',
        name: visitor.anonymized_name.titleize,
        banned_until: visitor.banned_until.to_s(:short_nomis),
        scope: %i[visitor_mailer rejected])
    else
      h.t('visitor_banned_html',
        name: visitor.anonymized_name.titleize,
        scope: %i[visitor_mailer rejected])
    end
  end

  def email_visitor_not_on_list_explanation
    h.t(
      'visitor_not_on_list_html',
      visitors: visit.unlisted_visitors.map(&:anonymized_name).to_sentence,
      scope: %i[visitor_mailer rejected]
    )
  end

  def apply_nomis_reasons
    if unbookable?
      reasons << Rejection::NO_ALLOWANCE if no_allowance?
      reasons << Rejection::PRISONER_BANNED if prisoner_banned?
      if prisoner_out_of_prison?
        reasons << Rejection::PRISONER_OUT_OF_PRISON
      end
    end

    if prisoner_details_incorrect?
      reasons << Rejection::PRISONER_DETAILS_INCORRECT
    end
  end

private

  def prisoner_details_incorrect?
    prisoner_details.details_incorrect? ||
      prisoner_location.status == PrisonerLocationValidation::INVALID
  end

  def email_reasons
    object.reasons.reject do |reason|
      reason.in? [Rejection::OTHER_REJECTION_REASON, Rejection::VISITOR_OTHER_REASON]
    end
  end

  def email_formatted_reason(reason)
    if reason.in? RESTRICTON_REASONS
      email_translated_restricted_reason
    else
      email_translated_explanations_for(reason)
    end
  end

  def nomis_checker
    h.nomis_checker
  end

  def prisoner_details
    h.prisoner_details
  end

  def prisoner_location
    h.prisoner_location_presenter
  end

  def unbookable?
    future_slots.any? &&
      future_slots.all? { |slot| nomis_checker.errors_for(slot).any? }
  end

  def no_allowance?
    visit.slots.any? { |slot| nomis_checker.no_allowance?(slot) }
  end

  def prisoner_banned?
    visit.slots.any? { |slot| nomis_checker.prisoner_banned?(slot) }
  end

  def prisoner_out_of_prison?
    visit.slots.any? { |slot| nomis_checker.prisoner_out_of_prison?(slot) }
  end

  def future_slots
    @future_slots ||= visit.slots.select { |slot| slot.to_date.future? }
  end

  def email_slot_unavailable_explanation
    h.t(
      'slot_unavailable_html',
      prisoner: visit.prisoner_anonymized_name,
      prison:   visit.prison_name,
      scope:   %i[visitor_mailer rejected]
    )
  end

  def email_no_allowance_explanation
    key = if object.allowance_renews_on?
            'no_allowance_date_html'
          else
            'no_allowance_html'
          end
    h.t(
      key,
      scope: %i[visitor_mailer rejected],
      date: h.format_date_without_year(object.allowance_renews_on)
    )
  end

  def date_to_accessible_date(date)
    return date if date.is_a?(Hash)
    {
      year:  date.year,
      month: date.month,
      day:   date.day
    }
  end

  # rubocop:disable Metrics/MethodLength
  def email_translated_explanations_for(reason)
    case reason
    when Rejection::SLOT_UNAVAILABLE
      [Rejection::Reason.new(explanation: email_slot_unavailable_explanation)]
    when Rejection::NO_ALLOWANCE
      [Rejection::Reason.new(explanation: email_no_allowance_explanation)]
    when Rejection::NOT_ON_THE_LIST
      [Rejection::Reason.new(explanation: email_visitor_not_on_list_explanation)]
    when Rejection::BANNED
      email_visitor_rejection_reasons
    else
      [Rejection::Reason.new(
        explanation: h.t("#{reason}_html", scope: %i[visitor_mailer rejected])
      )]
    end
  end
  # rubocop:enable Metrics/MethodLength

  def email_visitor_rejection_reasons
    visit.banned_visitors.map do |visitor|
      Rejection::Reason.new(explanation: email_visitor_banned_explanation(visitor))
    end
  end

  def email_translated_restricted_reason
    explanation = h.t('restricted_reason', scope: %i[visitor_mailer rejected])
    [Rejection::Reason.new(explanation: explanation)]
  end

  def staff_no_allowance_explanation(allowance_renews_on)
    if allowance_renews_on
      h.t("no_allowance_#{allowance_renews_on.future?}",
        vo_date: h.format_date_without_year(allowance_renews_on), scope: :shared)
    else
      h.t('no_allowance', scope: :shared)
    end
  end

  def staff_other_explanation(detail)
    h.t('other_reason', detail: detail, scope: :shared)
  end
end
