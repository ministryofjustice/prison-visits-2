require 'rails_helper'

RSpec.describe ZendeskCleaner do
  let(:client) { double(ZendeskAPI::Client) }
  let(:ticket1) { double(ZendeskAPI::Ticket, id: 1) }
  let(:ticket2) { double(ZendeskAPI::Ticket, id: 2) }
  let(:ticket3) { double(ZendeskAPI::Ticket, id: 3) }
  let(:tickets) { double(ZendeskAPI::Collection) }
  let(:ticket_ids) { [ticket1.id, ticket2.id, ticket3.id] }

  subject { described_class.new }

  context 'when Zendesk is configured' do
    it 'successfully bulk deletes tickets older than 12 months old' do
      Rails.configuration.zendesk_client = client
      query = "type:ticket tags:staff.prison.visits created<#{twelve_months_ago}"

      expect(client).to receive(:search).with(query: query).and_return(tickets)
      expect(tickets).to receive(:map).and_return(ticket_ids)
      expect(ZendeskAPI::Ticket).
        to receive(:destroy_many!).
          with(client, ids: ticket_ids).
          once

      subject.delete_tickets
    end
  end

  def twelve_months_ago
    Time.zone.today.months_ago(12).strftime("%Y-%m-%d")
  end
end
