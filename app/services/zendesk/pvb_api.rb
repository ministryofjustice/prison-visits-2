module Zendesk
  class PVBApi
    def initialize(zendesk_pvb_client)
      self.zendesk_pvb_client = zendesk_pvb_client
    end

    def raise_ticket(ticket_attrs)
      request do |client|
        ZendeskAPI::Ticket.create!(client, ticket_attrs)
      end
    end

    def cleanup_tickets
      unless ticket_ids.empty?
        destroy_tickets(ticket_ids)
      end
    end

  private

    attr_accessor :zendesk_pvb_client

    STAFF_INBOX = 'staff.prison.visits'.freeze

    def ticket_ids
      request { |client| client.search(old_tickets_query).map(&:id) }
    end

    def destroy_tickets(ids)
      request do |client|
        client.tickets.destroy_many!(ids: ids, verb: :delete).fetch
      end
    end

    def twelve_months_ago
      12.months.ago.strftime('%Y-%m-%d')
    end

    def old_tickets_query
      {
        query: "type:ticket tags:#{STAFF_INBOX} updated<#{twelve_months_ago}",
        reload: true
      }
    end

    def request(&block)
      zendesk_pvb_client.request(&block)
    end
  end
end
