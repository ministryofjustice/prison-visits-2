# frozen_string_literal: true
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

  def checkbox_for(reason, html_options = {})
    h.check_box_tag(
      'visit[rejection_attributes][reasons][]',
      reason,
      object.reasons.include?(reason.to_s),
      html_options
    )
  end

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

  def visitor_banned_explanation(visitor)
    if visitor.banned_until?
      h.t('visitor_banned_until_html',
        name: visitor.anonymized_name.titleize,
        banned_until: visitor.banned_until.to_s(:short_nomis),
        scope: [:visitor_mailer, :rejected])
    else
      h.t('visitor_banned_html',
        name: visitor.anonymized_name.titleize,
        scope: [:visitor_mailer, :rejected])
    end
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
    key = if object.allowance_renews_on?
            'no_allowance_date_html'
          else
            'no_allowance_html'
          end
    h.t(
      key,
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
  def translated_explanations_for(reason)
    case reason
    when Rejection::SLOT_UNAVAILABLE
      Rejection::Reason.new(explanation: slot_unavailable_explanation)
    when Rejection::NO_ALLOWANCE
      Rejection::Reason.new(explanation: no_allowance_explanation)
    when Rejection::NOT_ON_THE_LIST
      Rejection::NotOnList.new(explanation: visitor_not_on_list_explanation)
    when Rejection::BANNED
      visitor_rejection_reasons
    else
      Rejection::Reason.new(
        explanation: h.t("#{reason}_html", scope: [:visitor_mailer, :rejected])
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def visitor_rejection_reasons
    visit.banned_visitors.map do |visitor|
      Rejection::Reason.new(explanation: visitor_banned_explanation(visitor))
    end
  end

  def translated_restricted_reason
    explanation = h.t('restricted_reason', scope: [:visitor_mailer, :rejected])
    Rejection::Reason.new(explanation: explanation)
  end
end
