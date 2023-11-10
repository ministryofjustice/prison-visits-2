class CancellationDecorator < Draper::Decorator
  delegate_all

  RESTRICTON_REASONS = [
    Cancellation::CHILD_PROTECTION_ISSUES,
    Cancellation::PRISONER_NON_ASSOCIATION
  ].freeze

  def formatted_reasons
    result = []

    if object.reasons.any? { |r| r.in? RESTRICTON_REASONS }
      result << translated_restricted_reason
    end

    non_restricted_reasons = object.reasons - RESTRICTON_REASONS

    non_restricted_reasons.each do |reason|
      explanations = *translated_explanations_for(reason)
      result += explanations
    end
    result
  end

  def staff_cancellation_reasons
    @staff_cancellation_reasons ||= Cancellation::STAFF_REASONS.map { |reason|
      Cancellation::Reason.new(
        id: reason,
        label: I18n.t(".#{reason}", scope: %i[prison visits cancel_visit])
      )
    }
  end

private

  def translated_explanations_for(reason)
    Cancellation::Reason.new(explanation: reason_explanation(reason))
  end

  def reason_explanation(reason)
    h.t(
      "#{reason}_html",
      prison: object.visit.prison_name,
      prisoner: object.visit.prisoner_full_name,
      visitor_name: object.visit.visitor_full_name,
      service_url: h.link_directory.public_service,
      scope: %i[visitor_mailer cancelled]
    )
  end

  def translated_restricted_reason
    explanation = h.t('restricted_reason_html', scope: %i[visitor_mailer cancelled])
    Cancellation::Reason.new(explanation:)
  end
end
