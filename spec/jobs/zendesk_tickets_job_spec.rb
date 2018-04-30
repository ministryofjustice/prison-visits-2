require 'rails_helper'

RSpec.describe ZendeskTicketsJob, type: :job do
  subject { described_class }

  let!(:feedback) {
    FeedbackSubmission.create!(
      body: 'text',
      email_address: 'email@example.com',
      referrer: 'ref',
      user_agent: 'Mozilla',
      submitted_by_staff: submitted_by_staff
    )
  }

  let(:client) { double(ZendeskAPI::Client) }
  let(:ticket) { double(ZendeskAPI::Ticket, save!: nil) }
  let(:submitted_by_staff) { false }
  let(:prison) { FactoryBot.create(:prison) }

  let(:url_custom_field) do
    { id: ZendeskTicketsJob::URL_FIELD, value: 'ref' }
  end

  let(:browser_custom_field) do
    { id: ZendeskTicketsJob::BROWSER_FIELD, value: 'Mozilla' }
  end

  let(:service_custom_field) do
    { id: ZendeskTicketsJob::SERVICE_FIELD, value: 'prison_visits' }
  end

  let(:prison_custom_field) do
    { id: ZendeskTicketsJob::PRISON_FIELD, value: prison.name }
  end

  before do
    Rails.configuration.zendesk_client = client
  end

  context 'when Zendesk is not configured' do
    it 'raises an error if Zendesk is not configured' do
      allow(Rails).to receive(:configuration).and_return(Class.new)

      expect {
        subject.perform_now(feedback)
      }.to raise_error('Cannot create Zendesk ticket since Zendesk not configured')
    end
  end

  it 'calls save! to send the feedback' do
    allow(ZendeskAPI::Ticket).
      to receive(:new).
      and_return(ticket)
    expect(ticket).to receive(:save!).once
    subject.perform_now(feedback)
  end

  describe 'when email not provided' do
    let(:feedback) {
      FeedbackSubmission.new(
        body: 'text',
        referrer: 'ref',
        user_agent: 'Mozilla'
      )
    }

    it 'creates a ticket with default email address' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          client,
          description: 'text',
          requester: { email: 'feedback@email.test.host', name: 'Unknown' },
          custom_fields: [
            url_custom_field,
            browser_custom_field,
            service_custom_field
          ]
      ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end

  context 'when feedback is associated to a prison' do
    before do
      feedback.prison = prison
    end

    it 'creates a ticket with custom fields containing the prison' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          client,
          description: 'text',
          requester: { email: 'email@example.com', name: 'Unknown' },
          custom_fields: [
            url_custom_field,
            browser_custom_field,
            prison_custom_field,
            service_custom_field
          ]
      ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end

  context 'when is submitted by the public' do
    let(:submitted_by_staff) { false }

    context 'with no prisoner fields filled in' do
      it 'creates a ticket with feedback and custom fields' do
        expect(ZendeskAPI::Ticket).
          to receive(:new).
          with(
            client,
            description: 'text',
            requester: { email: 'email@example.com', name: 'Unknown' },
            custom_fields: [
              url_custom_field,
              browser_custom_field,
              service_custom_field
            ]
        ).and_return(ticket)

        subject.perform_now(feedback)
      end
    end

    context 'with prisoner fields filled in' do
      before do
        feedback.prison = prison
        feedback.prisoner_number = prisoner_num
        feedback.prisoner_date_of_birth = prisoner_dob
      end

      let(:prisoner_num) { 'A1234BC' }
      let(:prisoner_dob) { Time.zone.today - 30.years }

      it 'creates a ticket with feedback and custom fields' do
        expect(ZendeskAPI::Ticket).
          to receive(:new).
          with(
            client,
            description: 'text',
            requester: { email: 'email@example.com', name: 'Unknown' },
            custom_fields: [
              url_custom_field,
              browser_custom_field,
              prison_custom_field,
              service_custom_field,
              { id: ZendeskTicketsJob::PRISONER_NUM_FIELD, value: prisoner_num },
              { id: ZendeskTicketsJob::PRISONER_DOB_FIELD, value: prisoner_dob }
            ]
        ).and_return(ticket)

        subject.perform_now(feedback)
      end
    end
  end

  context 'when is submitted by staff' do
    let(:submitted_by_staff) { true }

    it 'creates a ticket with feedback, custom fields and a tag' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          client,
          description: 'text',
          requester: { email: 'email@example.com', name: 'Unknown' },
          tags: ['staff.prison.visits'],
          custom_fields: [
            url_custom_field,
            browser_custom_field
          ]
      ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end

  context 'when raising a ticket is successful' do
    it 'deletes the feedback submission' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          client,
          description: 'text',
          requester: { email: 'email@example.com', name: 'Unknown' },
          custom_fields: [
            url_custom_field,
            browser_custom_field,
            service_custom_field
          ]
      ).and_return(ticket)

      subject.perform_now(feedback)

      expect(FeedbackSubmission.where(email_address: 'email@example.com')).not_to exist
    end
  end

  context 'when raising a ticket is not successful' do
    it 'does not delete the feedback submission' do
      allow(ticket).to receive(:save!).and_raise(ZendeskAPI::Error::ClientError.new('Error'))

      allow(ZendeskAPI::Ticket).
        to receive(:new).
          with(
            client,
            description: 'text',
            requester: { email: 'email@example.com', name: 'Unknown' },
            custom_fields: [
              url_custom_field,
              browser_custom_field,
              service_custom_field
            ]
          ).and_return(ticket)

      expect { subject.perform_now(feedback) }.to raise_error(ZendeskAPI::Error::ClientError)
      expect(FeedbackSubmission.where(email_address: 'email@example.com')).to exist
    end
  end
end
