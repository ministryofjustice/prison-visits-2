require 'notifications/client'

class GovNotifyEmailer
  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(visit, template_id)
    @client.send_email(
      email_address: visit.contact_email_address,
      template_id: template_id,
      personalisation: {
        visitor_first_name: visit.visitor_first_name,
        where_to_check_status_html: link_directory.visit_status(visit, locale: I18n.locale),
        when_to_expect_response: format_date_without_year(visit.confirm_by),
        when_to_check_spam: format_date_without_year(visit.confirm_by),
        add_address: address_book.no_reply,
        prison: visit.prison_name,
        count: pluralize(visit.total_number_of_visitors, 'person'),
        choice: choice_slots(visit),
        prisoner: visit.prisoner_anonymized_name,
        prisoner_number: visit.prisoner_number.upcase,
        visit_id: visit.human_id,
        phone: visit.prison_phone_no,
        email_address: visit.prison_email_address,
        feedback_url: link_directory.feedback_submission(locale: I18n.locale)
      }
    )
  end

  def choice_slots(visit)
    visit.slots.each_with_index do |slot, _index|
      format_slot_for_public(slot)
    end
  end
end
