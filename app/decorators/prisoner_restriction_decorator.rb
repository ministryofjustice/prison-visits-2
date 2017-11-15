class PrisonerRestrictionDecorator < Draper::Decorator
  delegate_all

  def formatted_date
    if expiry_date
      [
        effective_date.to_s(:short_nomis),
        h.t('to', scope: :shared),
        expiry_date.to_s(:short_nomis)
      ].join(' ')
    else
      effective_date.to_s(:short_nomis)
    end
  end
end
