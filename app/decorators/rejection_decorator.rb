class RejectionDecorator < Draper::Decorator
  delegate_all

  RESTRICTON_REASONS = [
    Rejection::PRISONER_NON_ASSOCIATION,
    Rejection::CHILD_PROTECTION_ISSUES
  ].freeze

  def allowance_renews_on
    @allowance_renews_on ||=
      begin
        if object.allowance_renews_on
          AccessibleDate.new(
            date_to_accessible_date(object.allowance_renews_on)
          )
        else
          AccessibleDate.new
        end
      end
  end

  def privileged_allowance_expires_on
    @privileged_allowance_expires_on ||=
      begin
        if object.privileged_allowance_expires_on
          AccessibleDate.new(
            date_to_accessible_date(object.privileged_allowance_expires_on)
          )
        else
          AccessibleDate.new
        end
      end
  end

  def checkbox_for(reason, html_options = {})
    h.check_box_tag(
      'visit[rejection_attributes][reasons][]',
      reason,
      object.reasons.include?(reason.to_s),
      html_options
    )
  end

  def formated_reasons
    raw_reasons = object.reasons.dup
    reason_objs = []
    while raw_reasons.any?
      reason = raw_reasons.pop
      raw_reasons.delete_if do |r|
        RESTRICTON_REASONS.include?(r)
      end

      reason_objs << translated_explanation_for(reason)
    end
    reason_objs
  end

  def visitor_banned_explanation
    h.t(
      'visitor_banned_html',
      visitors: visit.banned_visitors.map { |uv|
        uv.anonymized_name.titleize
      }.to_sentence,
      count: visit.banned_visitors.size,
      scope: [:visitor_mailer, :rejected]
    )
  end

  def visitor_not_on_list_explanation
    h.t(
      'visitor_not_on_list_html',
      visitors: visit.unlisted_visitors.map(&:anonymized_name).to_sentence,
      scope: [:visitor_mailer, :rejected]
    )
  end

private

  def slot_unavailable_explanation
    h.t(
      'slot_unavailable_html',
      prisoner: visit.prisoner_anonymized_name,
      prison:   visit.prison_name,
      scope:   [:visitor_mailer, :rejected]
    )
  end

  def no_allowance_explanation
    h.t(
      'no_allowance_html',
      scope: [:visitor_mailer, :rejected],
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
  def translated_explanation_for(reason)
    case reason
    when Rejection::SLOT_UNAVAILABLE
      Rejection::Reason.new(explanation: slot_unavailable_explanation)
    when Rejection::NO_ALLOWANCE
      Rejection::Reason.new(explanation: no_allowance_explanation)
    when Rejection::NOT_ON_THE_LIST
      Rejection::NotOnList.new(explanation: visitor_not_on_list_explanation)
    when Rejection::BANNED
      Rejection::Reason.new(explanation: visitor_banned_explanation)
    when *RESTRICTON_REASONS
      Rejection::Reason.new(
        explanation: h.t("#{reason}_html", scope: [:visitor_mailer, :rejected])
      )
    else
      Rejection::Reason.new(
        explanation: h.t("#{reason}_html", scope: [:visitor_mailer, :rejected])
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
end
