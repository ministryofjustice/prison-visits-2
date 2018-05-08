require 'rails_helper'

RSpec.describe ZendeskCleaner do
  subject { described_class.new }

  let(:client) { double(ZendeskAPI::Client) }
  let(:ticket1) { double(ZendeskAPI::Ticket, id: 1) }
  let(:ticket2) { double(ZendeskAPI::Ticket, id: 2) }
  let(:ticket3) { double(ZendeskAPI::Ticket, id: 3) }
  let(:tickets) { [ticket1, ticket2, ticket3] }

  context 'when Zendesk not configured' do
    it 'raises an error if Zendesk is not conifigured' do
      expect(Rails).to receive(:configuration).and_return(Class.new)

      expect {
        subject.delete_tickets
      }.to raise_error('Cannot delete Zendesk tickets as Zendesk is not configured')
    end
  end

  context 'when Zendesk is configured' do
    it 'successfully bulk deletes tickets older than 12 months old' do
      Rails.configuration.zendesk_client = client

      ids = tickets.map(&:id)
      query = "type:ticket tags:staff.prison.visits created<#{twelve_months_ago}"

      expect(client).to receive(:search).with(query: query).and_return(tickets)
      expect(ZendeskAPI::Ticket).
        to receive(:destroy_many!).
          with(client, ids: ids).
          once

      subject.delete_tickets
    end
  end

  def twelve_months_ago
    Time.zone.today.months_ago(12).strftime("%Y-%m-%d")
  end
end
