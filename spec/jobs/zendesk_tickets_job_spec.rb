# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ZendeskTicketsJob, type: :job do
  subject { described_class }

  let(:feedback) {
    FeedbackSubmission.new(
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

  before do
    Rails.configuration.zendesk_client = client
  end

  context 'Zendesk is not configured' do
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
            { id: '23730083', value: 'ref' },
            { id: '23791776', value: 'Mozilla' },
            { id: '23757677', value: 'prison_visits' }
          ]
        ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end

  context 'when feedback is associated to a prison' do
    let(:prison) { FactoryGirl.create(:prison) }

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
            { id: '23730083', value: 'ref' },
            { id: '23791776', value: 'Mozilla' },
            { id: '23984153', value: prison.name },
            { id: '23757677', value: 'prison_visits' }
          ]
        ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end

  context 'when is submitted by the public' do
    let(:submitted_by_staff) { false }

    it 'creates a ticket with feedback and custom fields' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          client,
          description: 'text',
          requester: { email: 'email@example.com', name: 'Unknown' },
          custom_fields: [
            { id: '23730083', value: 'ref' },
            { id: '23791776', value: 'Mozilla' },
            { id: '23757677', value: 'prison_visits' }
          ]
        ).and_return(ticket)
      subject.perform_now(feedback)
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
            { id: '23730083', value: 'ref' },
            { id: '23791776', value: 'Mozilla' }
          ]
        ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end
end
