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
        cancel_intro_date: visit.slot_granted,
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
        any_questions: any_questions(visit)
      }
    )
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
    if visit.banned_visitors.any? && !rejection.reasons.include?('visitor_banned')
      visit.banned_visitors.each do |v|
        rejection.email_visitor_banned_explanation(v)
      end
    else
      ''
    end
  end

  def unlisted_visitors(visit, rejection)
    if visit.unlisted_visitors.any? && !rejection.reasons.include?('visitor_not_on_list')
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
        $cant_visit_text = nil
        $rejection_intro_text = "We haven't booked your visit to #{visit.prisoner_anonymized_name} at #{visit.prison_name} because
                you've already requested a visit for the same date and time at this prison.
                We've sent you a separate email about your other visit request.
                Please click the link in that email to check the status of your request"
      elsif rejection.email_formatted_reasons.empty?
        $cant_visit_text = nil
        $rejection_intro_text = "We've not been able to book your visit to #{visit.prison_name}. Please do NOT go to the prison as you won't be able to get in."
      else
        $cant_visit_text = "You can't visit because:"
        $rejection_intro_text = "We've not been able to book your visit to #{visit.prison_name}. Please do NOT go to the prison as you won't be able to get in."
        rejection.email_formatted_reasons.first.explanation
      end
    end
  end
end
