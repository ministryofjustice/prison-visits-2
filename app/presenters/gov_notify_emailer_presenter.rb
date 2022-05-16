class GovNotifyEmailerPresenter
  include DateHelper
  include LinksHelper

  def one_off_message_text(message)
    returned_message = ''

    if message.nil? || message.body.nil?
      returned_message = ''
    else
      returned_message = message.body
    end

    returned_message
  end

  def cancellation_reasons(cancellation)
    cancellation_reasons = ''

    unless cancellation.nil?
      if cancellation.reasons.one?
        cancellation_reasons = cancellation.formatted_reasons.first.explanation
      else
        cancellation_reasons = cancellation.formatted_reasons.map(&:explanation)
      end
    end

    cancellation_reasons
  end

  def booked_subject_date(visit)
    slot_date = ''
    if visit.slot_granted == nil
      slot_date = ''
    else
      slot_date = format_slot_for_public(visit.slot_granted)
    end

    slot_date
  end

  def what_not_to_bring_text(visit)
    text = ''
    if visit.prison.name == 'Medway Secure Training Centre'
      text = "Please don't bring anything restricted or illegal to the prison. For more information about what you can't bring call the prison on #{visit.prison_phone_no}."
    else
      text = "Please don't bring anything restricted or illegal to the prison. The prison page has more information about what you can bring #{link_directory.prison_finder(visit.prison)}."
    end

    text
  end
end
