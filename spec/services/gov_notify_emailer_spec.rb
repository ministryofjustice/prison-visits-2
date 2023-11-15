require 'rails_helper'

RSpec.describe GovNotifyEmailer do
  include DateHelper
  include LinksHelper

  subject(:gov_notify_emailer) { described_class.new(client) }

  let(:client) { instance_double(Notifications::Client, send_email: true) }

  describe '#send_email' do
    let(:visit) { create(:visit) }
    let(:slot) { visit.slots.first }
    let(:template_id) { SecureRandom.uuid }
    let(:client_params) do
      {
        email_address: visit.contact_email_address,
        template_id:,
        personalisation: {
          receipt_date: format_date_without_year(visit.first_date),
          visitor_full_name: visit.visitor_first_name,
          where_to_check_status_html: link_directory.visit_status(visit, locale: I18n.locale),
          when_to_expect_response: format_date_without_year(visit.confirm_by),
          when_to_check_spam: format_date_without_year(visit.confirm_by),
          add_address: address_book.no_reply,
          prison: visit.prison_name,
          count: visit.total_number_of_visitors,
          choices: ["Choice 1: #{format_slot_for_public(slot)}"],
          prisoner: visit.prisoner_anonymized_name,
          prisoner_number: visit.prisoner_number.upcase,
          visit_id: visit.human_id,
          phone: visit.prison_phone_no,
          prison_email_address: visit.prison_email_address,
          feedback_url: link_directory.feedback_submission(locale: I18n.locale),
          booked_subject_date: "",
          prisoner_full_name: visit.prisoner_full_name,
          prison_website: link_directory.prison_finder(visit.prison),
          rejection_reasons: nil,
          rejection_intro_text: "We've not been able to book your visit to #{visit.prison_name}. Please do not go to the prison as you won't be able to get in.",
          cant_visit_text: "You can't visit because:",
          unlisted_visitors_text: "",
          update_list: "",
          first_visit: "",
          banned_visitors: "",
          message_from_prison: "",
          any_questions: "If you have any questions, visit the prison website\n      #{link_directory.prison_finder(visit.prison)}\n      or call the prison on #{visit.prison_phone_no}.",
          allowed_visitors: ["Visitor 1: #{visit.allowed_visitors.first.anonymized_name}"],
          reference_no: visit.reference_no,
          closed_visit: "",
          booking_accept_banned_visitors: " ",
          booking_accept_unlisted_visitors: " ",
          visitors_rejected_for_other_reasons: "",
          cancel_url: link_directory.visit_status(visit, locale: I18n.locale),
          cancellation_reasons: "",
          one_off_message_text: ""
        }
      }
    end

    context 'when rejection.nil?' do
      let(:rejection) { nil }

      before do
        gov_notify_emailer.send_email(visit, template_id)
      end

      it 'uses the default values' do
        expect(client).to have_received(:send_email).with(client_params)
      end
    end

    context 'when the !rejection.nil?' do
      let(:rejection) { visit.rejection.decorate }

      before do
        allow_any_instance_of(BookingResponder).to receive(:respond!)

        gov_notify_emailer.send_email(visit, template_id, rejection)
      end

      context 'when rejection.email_formatted_reasons.size > 1' do
        let(:visit) { create(:rejected_visit, rejection_attributes: { reasons: [Rejection::SLOT_UNAVAILABLE, Rejection::NOT_ON_THE_LIST] }) }

        it  do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                rejection_reasons: ["the dates and times you chose aren't available - choose new dates on https://www.gov.uk/prison-visits",
                                    "details for  don't match our records or aren't on the prisoner's contact list - ask the prisoner to update their contact list with correct details, making sure that names appear exactly the same as on ID documents; if this is the prisoner's first visit (reception visit), then you need to contact the prison directly to book"]

              }
            )
          )
        end
      end

      # The second elsif in the GovNotifyEmailer doesn’t seem to be ever true and therefore the included text never gets returned.
      #
      xcontext 'with rejection.email_formatted_reasons.first == "duplicate_visit_request"' do
        let(:visit) { create(:rejected_visit, rejection_attributes: { reasons: ['duplicate_visit_request'] }) }

        it do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                rejection_reasons: ["We haven't booked your visit to #{visit.prisoner_anonymized_name} at #{visit.prison_name} because
                you've already requested a visit for the same date and time at this prison.
                We've sent you a separate email about your other visit request.
                Please click the link in that email to check the status of your request"],
                rejection_intro_text: "We haven't booked your visit to #{visit.prisoner_anonymized_name} at #{visit.prison_name} because
                you've already requested a visit for the same date and time at this prison.
                We've sent you a separate email about your other visit request.
                Please click the link in that email to check the status of your request",
                cant_visit_text: "",
              }
            )
          )
        end
      end

      context 'with rejection.email_formatted_reasons.empty?' do
        let(:visit) { create(:rejected_visit, rejection_attributes: { reasons: [Rejection::BANNED] }) }

        it do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                rejection_reasons: "We've not been able to book your visit to #{visit.prison_name}. Please do not go to the prison as you won't be able to get in.",
                rejection_intro_text: "We've not been able to book your visit to #{visit.prison_name}. Please do not go to the prison as you won't be able to get in.",
                cant_visit_text: "",
              }
            )
          )
        end
      end

      context 'with anything else' do
        let(:visit) { create(:rejected_visit, rejection_attributes: { reasons: [Rejection::PRISONER_OUT_OF_PRISON] }) }

        it do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                rejection_reasons: "the prisoner has a restriction",
                rejection_intro_text: "We've not been able to book your visit to #{visit.prison_name}. Please do not go to the prison as you won't be able to get in.",
                cant_visit_text: "You can't visit because:",
              }
            )
          )
        end
      end
    end

    context 'when message.nil?' do
      before do
        gov_notify_emailer.send_email(visit, template_id)
      end

      it do
        expect(client).to have_received(:send_email).with(client_params)
      end
    end

    context 'when !message.nil?' do
      let(:message) { create(:message) }

      before do
        gov_notify_emailer.send_email(visit, template_id, nil, message)
      end

      context 'with !message.body.nil?' do
        it do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                message_from_prison: "Message from the prison: #{message.body}",
                one_off_message_text: message.body
              }
            )
          )
        end
      end

      context 'with message.body.nil?' do
        let(:message) { build(:message, body: nil) }

        it do
          expect(client).to have_received(:send_email).with(
            client_params.deep_merge(
              personalisation: {
                message_from_prison: "",
                one_off_message_text: ""
              }
            )
          )
        end
      end
    end
  end
end
