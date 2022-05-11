require 'notifications/client'

class GovNotifyEmailer
  include DateHelper
  include LinksHelper

  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(visit, template_id)
    @client.send_email(
      email_address: visit.contact_email_address,
      template_id: template_id,
      personalisation: {
        receipt_date: format_date_without_year(visit.first_date),
        cancellation_date: format_date_without_year(visit.date),
        visitor_full_name: visit.visitor_first_name,
        where_to_check_status_html: link_directory.visit_status(visit, locale: I18n.locale),
        when_to_expect_response: format_date_without_year(visit.confirm_by),
        when_to_check_spam: format_date_without_year(visit.confirm_by),
        add_address: address_book.no_reply,
        prison: visit.prison_name,
        count: visit.total_number_of_visitors,
        choice: 'yas',
        prisoner: visit.prisoner_anonymized_name,
        prisoner_number: visit.prisoner_number.upcase,
        visit_id: visit.human_id,
        phone: visit.prison_phone_no,
        prison_email_address: visit.prison_email_address,
        feedback_url: link_directory.feedback_submission(locale: I18n.locale),
        cancel_intro_date: format_slot_for_public(visit.slot_granted),
        prisoner_full_name: visit.prisoner_full_name,
        prison_website: link_directory.prison_finder(visit.prison)
      }
    )
  end
end
