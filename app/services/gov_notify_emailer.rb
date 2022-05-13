require 'notifications/client'

class GovNotifyEmailer
  include DateHelper
  include LinksHelper

  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(visit, template_id, rejection = nil, message = nil)
    $rejection_intro_text = "We've not been able to book your visit to #{visit.prison_name}. Please do NOT go to the prison as you won't be able to get in."
    $cant_visit_text = "You can't visit because:"

    $update_list = ''
    $first_visit = ''

    @client.send_email(
      email_address: visit.contact_email_address,
      template_id: template_id,
      personalisation: {
        receipt_date: format_date_without_year(visit.first_date),
        visitor_full_name: visit.visitor_first_name,
        where_to_check_status_html: link_directory.visit_status(visit, locale: I18n.locale),
        when_to_expect_response: format_date_without_year(visit.confirm_by),
        when_to_check_spam: format_date_without_year(visit.confirm_by),
        add_address: address_book.no_reply,
        prison: visit.prison_name,
        count: visit.total_number_of_visitors,
        choices: slot_choices(visit),
        prisoner: visit.prisoner_anonymized_name,
        prisoner_number: visit.prisoner_number.upcase,
        visit_id: visit.human_id,
        phone: visit.prison_phone_no,
        prison_email_address: visit.prison_email_address,
        feedback_url: link_directory.feedback_submission(locale: I18n.locale),
        booked_subject_date: booked_subject_date(visit),
        prisoner_full_name: visit.prisoner_full_name,
        prison_website: link_directory.prison_finder(visit.prison),
        rejection_reasons: rejection_reasons(visit, rejection),
        rejection_intro_text: $rejection_intro_text,
        cant_visit_text: $cant_visit_text,
        unlisted_visitors_text: unlisted_visitors(visit, rejection),
        update_list: $update_list,
        first_visit: $first_visit,
        banned_visitors: banned_visitors(visit, rejection),
        message_from_prison: message_from_prison(message),
        any_questions: any_questions(visit),
        allowed_visitors: allowed_visitors(visit),
        reference_no: visit.reference_no,
        closed_visit: is_closed_visit(visit),
        booking_accept_banned_visitors: booking_accept_banned_visitors(visit),
        booking_accept_unlisted_visitors: booking_accept_unlisted_visitors(visit),
        visitors_rejected_for_other_reasons: visitors_rejected_for_other_reasons(visit),
        cancel_url: override_cancel_link(visit),
        what_not_to_bring_text: what_not_to_bring_text(visit),
        cancellation_reasons: cancellation_reasons(visit)
      }
    )
  end

  def cancellation_reasons(visit)
    cancellation = visit.cancellation.decorate

    cancellation_reasons = ''

    if cancellation.reasons.one?
      cancellation_reasons = cancellation.formatted_reasons.first.explanation
    else
      cancellation_reasons = cancellation.formatted_reasons.map(&:explanation)
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

  def override_cancel_link(visit)
    url = ''
    if @override_cancel_link
      url = prison_visit_url(visit, locale: I18n.locale)
    else
      url = link_directory.visit_status(visit, locale: I18n.locale)
    end
    url
  end

  def visitors_rejected_for_other_reasons(visit)
    message = ''

    if visit.visitors_rejected_for_other_reasons.any?
      visit.visitors_rejected_for_other_reasons.each do |v|
        message = "#{v.anonymized_name} cannot attend Please contact the prison for more information about why they can't attend."
      end
    end

    message
  end

  def booking_accept_unlisted_visitors(visit)
    message = ''
    not_on_list_instructions = 'Visitors not on contact lists need to ask prisoners to update their lists with correct details, making sure that names appear exactly the same as on ID documents.'

    if visit.unlisted_visitors.any?
      visit.unlisted_visitors.each do |v|
        message = "#{v.anonymized_name} cannot attend as they are not on the prisoner's contact list"
      end
    else
      message = ''
      not_on_list_instructions = ''
    end

    not_on_list_message = message + ' ' + not_on_list_instructions
    not_on_list_message
  end

  def booking_accept_banned_visitors(visit)
    message = ''
    banned_instructions = 'Banned visitors should have received a letter to say that they are
                            banned from visiting the prison at the moment. Get in touch with
                            the prison for more information.'

    if visit.banned_visitors.any?
      visit.banned_visitors.each do |v|
        if v.banned_until?
          message = "#{v.anonymized_name} cannot attend as they are currently banned until #{v.banned_until.to_s(:short_nomis)}"
        else
          message = "#{v.anonymized_name} cannot attend as they are currently banned "
        end
      end
    else
      message = ''
      banned_instructions = ''
    end

    banned_message = message + ' ' + banned_instructions
    banned_message
  end

  def is_closed_visit(visit)
    closed_visit_text = 'This is a closed visit: the prisoner will be behind a glass screen in a separate area rather than in the visiting hall.'

    if visit.closed?
      closed_visit_text
    else
      ''
    end
  end

  def allowed_visitors(visit)
    visitors = []
    visit.allowed_visitors.each_with_index do |visitor, index|
      visitors.push("Visitor #{index + 1}: " + visitor.anonymized_name)
    end
    visitors
  end

  def any_questions(visit)
    if visit.prison.name == 'Medway Secure Training Centre'
      "If you have any questions, call the prison #{visit.prison_phone_no} on ."
    else
      "If you have any questions, visit the prison website
      #{link_directory.prison_finder(visit.prison)}
      or call the prison on #{visit.prison_phone_no}."
    end
  end

  def message_from_prison(message)
    if message&.body.present?
      'Message from the prison: ' + message.body
    else
      ''
    end
  end

  def banned_visitors(visit, rejection)
    if rejection.nil?
      ''
    elsif visit.banned_visitors.any? && !rejection.reasons.include?('visitor_banned')
      visit.banned_visitors.each do |v|
        rejection.email_visitor_banned_explanation(v)
      end
    else
      ''
    end
  end

  def unlisted_visitors(visit, rejection)
    if rejection.nil?
      $update_list = ''
      $first_visit = ''
      ''
    elsif visit.unlisted_visitors.any? && !rejection.reasons.include?('visitor_not_on_list')
      $update_list = 'Please contact the prisoner and ask them to update their contact list with correct details, making sure that names appear exactly the same as on ID documents.'
      $first_visit = "If this is the prisoner's first visit (reception visit), then you need to contact the prison to book."
      rejection.email_visitor_not_on_list_explanation
    else
      $update_list = ''
      $first_visit = ''
      ''
    end
  end

  def slot_choices(visit)
    slots = []
    visit.slots.each_with_index do |slot, index|
      slots.push("Choice #{index + 1}: " + format_slot_for_public(slot))
    end
    slots
  end

  def rejection_reasons(visit, rejection)
    unless rejection.nil?
      if rejection.email_formatted_reasons.size > 1
        rejection.email_formatted_reasons.map(&:explanation)
      elsif rejection.email_formatted_reasons.first == 'duplicate_visit_request'
        $cant_visit_text = ''
        $rejection_intro_text = "We haven't booked your visit to #{visit.prisoner_anonymized_name} at #{visit.prison_name} because
                you've already requested a visit for the same date and time at this prison.
                We've sent you a separate email about your other visit request.
                Please click the link in that email to check the status of your request"
      elsif rejection.email_formatted_reasons.empty?
        $cant_visit_text = ''
        $rejection_intro_text = "We've not been able to book your visit to #{visit.prison_name}. Please do NOT go to the prison as you won't be able to get in."
      else
        $cant_visit_text = "You can't visit because:"
        $rejection_intro_text = "We've not been able to book your visit to #{visit.prison_name}. Please do NOT go to the prison as you won't be able to get in."
        rejection.email_formatted_reasons.first.explanation
      end
    end
  end
end
