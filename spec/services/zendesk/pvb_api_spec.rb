require 'rails_helper'

RSpec.describe Zendesk::PVBApi do
  let(:zendesk_api_client) { double(ZendeskAPI::Client) }
  let(:zendesk_pvb_client) { Zendesk::PVBClient.instance }

  subject { described_class.new(zendesk_pvb_client) }

  before do
    allow(zendesk_pvb_client).to receive(:request).and_yield(zendesk_api_client)
  end

  describe '#cleanup_tickets' do
    let(:ticket_ids) { [{ id: 1 }, { id: 2 }, { id: 3 }].map { |t| ZendeskAPI::Ticket.new(zendesk_api_client, t) } }
    let(:empty_ticket_ids) { [] }
    let(:empty_tickets) { ZendeskAPI::Collection.new(zendesk_api_client, ZendeskAPI::Ticket, ids: []) }
    let(:twelve_months_ago) { 12.months.ago.strftime('%Y-%m-%d') }
    let(:query) do
      {
        query: "type:ticket tags:staff.prison.visits updated<#{twelve_months_ago}",
        reload: true
      }
    end

    it 'deletes tickets that have not been updated in twelve months or less' do
      inbox = 'an.inbox.tag'

      expect(zendesk_api_client).to receive(:search)
        .and_return(ticket_ids, empty_ticket_ids)
      expect(ZendeskAPI::Ticket).to receive(:destroy_many!)
        .with(zendesk_api_client, ticket_ids).once

      subject.cleanup_tickets(inbox)
    end
  end

  describe '#raise_ticket' do
    let(:ticket) { double(ZendeskAPI::Ticket, save!: nil) }
    let(:submitted_by_staff) { false }
    let(:url_custom_field) do
      { id: ZendeskTicketsJob::URL_FIELD, value: 'ref' }
    end

    let(:browser_custom_field) do
      { id: ZendeskTicketsJob::BROWSER_FIELD, value: 'Mozilla' }
    end

    let(:service_custom_field) do
      { id: ZendeskTicketsJob::SERVICE_FIELD, value: 'prison_visits' }
    end
    let(:ticket_attributes) do
      {
        description: 'text',
        requester: { email: 'feedback@email.test.host', name: 'Unknown' },
        custom_fields: [
          url_custom_field,
          browser_custom_field,
          service_custom_field
        ]
      }
    end

    it 'calls save! to send the feedback' do
      expect(ZendeskAPI::Ticket)
        .to receive(:new)
        .with(
          zendesk_api_client,
          ticket_attributes
      )
      .and_return(ticket)

      expect(ticket).to receive(:save!).once

      subject.raise_ticket(ticket_attributes)
    end
  end
end
