require 'rails_helper'

RSpec.describe Zendesk::PvbApi do
  let(:client) { double(Zendesk::Client) }
  let(:url) { 'https://zendesk_api.com' }
  let(:username) { 'bob' }
  let(:token) { '123456' }

  subject { described_class.new(client) }

  before do
    set_configuration_with(:zendesk_url, url)
    set_configuration_with(:zendesk_username, username)
    set_configuration_with(:zendesk_token, token)
  end

  describe ':delete_old_tickets' do
    let(:ticket_ids) { [1, 2, 3] }
    let(:tickets) { double(ZendeskAPI::Collection) }
    let(:query) do
      {
        query: "type:ticket tags:staff.prison.visits updated<#{twelve_months_ago}",
        reload: true
      }
    end

    it 'deletes tickets that have not been updated in twelve months or less' do
      allow(tickets).to receive(:fetch)
      allow(client).to receive(:tickets).and_return(tickets)
      allow(client).
        to receive(:search).
          with(query).
          and_return(tickets)
      allow(tickets).
        to receive(:map).
          and_return(ticket_ids, ticket_ids, [])
      allow(client.tickets).
        to receive(:destroy_many).
          with(any_args).
          and_return(tickets)

      expect(client).
        to receive(:search).with(query).
          and_return(tickets)
      expect(client.tickets).
        to receive(:destroy_many).
          with(ids: ticket_ids, verb: :delete).
          once

      subject.cleanup_tickets
    end
  end

  describe ':raise_ticket' do
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
      expect(ZendeskAPI::Ticket).
        to receive(:new).
          with(
            client,
            ticket_attributes
          ).
          and_return(ticket)

      expect(ticket).to receive(:save!).once

      subject.raise_ticket(ticket_attributes)
    end
  end

  def twelve_months_ago
    Time.zone.today.months_ago(12).strftime("%Y-%m-%d")
  end
end
