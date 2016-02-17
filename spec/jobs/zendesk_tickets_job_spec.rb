require 'rails_helper'

RSpec.describe ZendeskTicketsJob, type: :job do
  subject { described_class }

  let(:feedback) {
    FeedbackSubmission.new(
      body: 'text',
      email_address: 'email@example.com',
      referrer: 'ref',
      user_agent: 'Mozilla'
    )
  }
  let(:client) { double(ZendeskAPI::Client) }
  let(:ticket) { double(ZendeskAPI::Ticket, save!: nil) }

  before :each do
    Rails.configuration.zendesk_client = client
  end

  it 'raises an error if Zendesk is not configured' do
    Rails.configuration.zendesk_client = nil

    expect {
      subject.perform_now(feedback)
    }.to raise_error('Cannot create Zendesk ticket since Zendesk not configured')
  end

  it 'creates a ticket with feedback and custom fields' do
    expect(ZendeskAPI::Ticket).
      to receive(:new).
      with(
        client,
        description: 'text',
        requester: { email: 'email@example.com', name: 'Unknown' },
        custom_fields: [
          { id: '23730083', value: 'ref' },
          { id: '23757677', value: 'prison_visits' },
          { id: '23791776', value: 'Mozilla' }
        ]
      ).and_return(ticket)
    subject.perform_now(feedback)
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
            { id: '23730083', value: 'ref' },
            { id: '23757677', value: 'prison_visits' },
            { id: '23791776', value: 'Mozilla' }
          ]
        ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end
end
