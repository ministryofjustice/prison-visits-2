require 'rails_helper'

RSpec.describe VisitorMailer do
  subject! { described_class }

  before do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(VisitorMailer).to receive(:smtp_domain).and_return('example.com')
    Prison.find('Rochester').lead_days = 0
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2013, 7, 4)) do
      example.run
    end
  end

  let(:email) {
    ParsedEmail.parse(
      from: "visitor@example.com",
      to: 'test@example.com',
      text: "some text",
      charsets: { to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8" }.to_json,
      subject: "important email"
    )
  }

  let :confirmation do
    Confirmation.new(message: 'A message', outcome: 'slot_0')
  end

  let :confirmation_canned_response do
    Confirmation.new(outcome: 'slot_0', vo_number: '5551234')
  end

  let :confirmation_canned_response_remand do
    Confirmation.new(outcome: 'slot_0', vo_number: 'none')
  end

  let :confirmation_unlisted_visitors do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0', visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :confirmation_banned_visitors do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0', visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let :confirmation_closed_visit do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0', closed_visit: true)
  end

  let :confirmation_no_slot_available do
    Confirmation.new(message: 'A message', outcome: Confirmation::NO_SLOT_AVAILABLE)
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(message: 'A message', outcome: Confirmation::NOT_ON_CONTACT_LIST)
  end

  let :rejection_prisoner_incorrect do
    Confirmation.new(outcome: Confirmation::PRISONER_INCORRECT)
  end

  let :rejection_prisoner_not_present do
    Confirmation.new(outcome: Confirmation::PRISONER_NOT_PRESENT)
  end

  let :rejection_prisoner_no_allowance do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE)
  end

  let :rejection_prisoner_no_allowance_vo_renew do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE, no_vo: true, renew_vo: '2014-11-29')
  end

  let :rejection_prisoner_no_allowance_pvo_renew do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE, no_vo: true, renew_vo: '2014-11-29', no_pvo: true, renew_pvo: '2014-11-17')
  end

  let :rejection_visitor_not_listed do
    Confirmation.new(visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :rejection_visitor_banned do
    Confirmation.new(visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let(:confirmation_no_vos_left) { Confirmation.new(message: 'A message', outcome: Confirmation::NO_VOS_LEFT) }
  let(:noreply_address) { Mail::Field.new('from', "Prison Visits Booking <no-reply@example.com> (Unattended)") }
  let(:visitor_address) { Mail::Field.new('to', "Mark Harris <visitor@example.com>") }
  let(:prison_email) { 'pvb.RCI@maildrop.dsd.io' }
  let(:prison_address) { Mail::Field.new('reply-to', prison_email) }
  let(:token) { MESSAGE_ENCRYPTOR.encrypt_and_sign(sample_visit) }

  it_behaves_like 'a mailer that ensures content transfer encoding is quoted printable'

  it "relays e-mails via sendgrid" do
    expect(VisitorMailer.smtp_settings).to eq(ActionMailer::Base.smtp_settings)
  end

  it "delivers an automated response" do
    expect {
      VisitorMailer.autorespond(email).tap do |m|
        expect(m[:from]).to eq(noreply_address)
        expect(m[:to]).to eq(visitor_address)
      end.deliver_now
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  shared_examples 'an email without spam and bounce reset checks' do
    it 'makes no attempt at resets' do
      expect_any_instance_of(SpamAndBounceResets).to_not receive(:perform_resets)
      email.deliver_now
    end
  end

  context "when booking is successful" do
    it_behaves_like 'an email without spam and bounce reset checks' do
      let(:email) { subject.booking_confirmation_email(sample_visit, confirmation, token) }
    end

    it "sends out an e-mail with a reference number" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_canned_response, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html('5551234')
      expect(email).not_to match_in_html("This is a copy")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with no reference number for remand prisoners" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_canned_response_remand, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).not_to match_in_html('Your reference number is')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with the list of visitors not on the approved visitor list" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_unlisted_visitors, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan H. cannot attend as they’re not on the prisoner’s contact list")
      expect(email).to match_in_html('5551234')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with the list of banned visitors" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_banned_visitors, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan H. cannot attend as they’re currently banned")
      expect(email).to match_in_html('5551234')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail notifying visitors that it is a closed visit" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_closed_visit, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html('5551234')
      expect(email).to match_in_html('This is a closed visit')
    end

    it "sends out an e-mail with the List-Unsubscribe header set" do
      header_value = '<https://www.prisonvisits.service.gov.uk/unsubscribe>'
      expect(subject.booking_receipt_email(sample_visit, "token")['List-Unsubscribe'].value).to eq(header_value)
      [confirmation_no_slot_available, confirmation_not_on_contact_list, confirmation_no_vos_left].each do |outcome|
        expect(subject.booking_rejection_email(sample_visit, outcome)['List-Unsubscribe'].value).to eq(header_value)
      end
      expect(subject.booking_confirmation_email(sample_visit, confirmation, token)['List-Unsubscribe'].value).to eq(header_value)
    end
  end

  context "sends out an unsuccessful e-mail with a date in the subject" do
    it_behaves_like 'an email without spam and bounce reset checks' do
      let(:email) { subject.booking_rejection_email(sample_visit, confirmation_no_slot_available) }
    end

    it "because of a slot not being available" do
      email = subject.booking_rejection_email(sample_visit, confirmation_no_slot_available)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because of a visitor not being on a contact list (legacy)" do
      email = subject.booking_rejection_email(sample_visit, confirmation_not_on_contact_list)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner details are incorrect" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_incorrect)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as you haven’t given correct information for the prisoner.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner is not at the prison" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_not_present)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as the prisoner you want to visit has moved prison.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance and a VO renewal date is specified" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance_vo_renew)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")
      expect(email).to match_in_html("Jimmy H will have their full visiting allowance (VO) renewed on Saturday 29 November.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance and a PVO renewal date is specified" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance_pvo_renew)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")
      expect(email).to match_in_html("However, you can book a weekday visit with visiting allowance valid until Monday 17 November.")
      expect(email).to match_in_html("Jimmy H will have their full visiting allowance (VO) renewed on Saturday 29 November.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because a visitor is not on the list (canned response)" do
      email = subject.booking_rejection_email(sample_visit, rejection_visitor_not_listed)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as details for Joan Harris don’t match our records or they aren’t on the prisoner’s contact list.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because a visitor is banned" do
      email = subject.booking_rejection_email(sample_visit, rejection_visitor_banned)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan Harris should have received a letter to say that they’re banned from visiting the prison at the moment.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end
  end

  context "booking receipt is sent" do
    before do
      # TODO: I dislike this as a solution, but seem unable to persist any changes to
      # Prison#lead_days when it is being accessed via the Visit model (at the time of
      # writing, Prison is a Virtus model.
      allow_any_instance_of(PrisonSchedule).to receive(:days_lead_time).
        and_return(double('days', zero?: true))
    end

    it "attempts spam and bounce resets" do
      expect_any_instance_of(SpamAndBounceResets).to receive(:perform_resets)
      subject.booking_receipt_email(sample_visit, token).deliver_now
    end

    it "with a date in the subject" do
      email = subject.booking_receipt_email(sample_visit, "token")
      expect(email.subject).to eq("Not booked yet: we've received your visit request for Sunday 7 July")
      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html(visit_status_url(id: sample_visit.visit_id))
      # On Rochester, using production data, this fails if lead_days is set to the default of 3.
      # This is because it breaks over a weekend and the next working day that qualifies is the 9th.
      # The issue is expalined here: https://www.pivotaltracker.com/story/show/105232814
      expect(email).to match_in_html("by Friday 5 July to")
      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end
  end

  it "sends an e-mail to the person who requested a booking" do
    expect(subject.booking_confirmation_email(sample_visit, confirmation, token)[:to]).to eq(visitor_address)
  end
end
