module Zendesk
  class PVBApi
    def initialize(zendesk_client)
      @pool = zendesk_client.pool
    end

    def raise_ticket(ticket_attrs)
      @pool.with do |client|
        ZendeskAPI::Ticket.create!(client, ticket_attrs)
      end
    end

    def cleanup_tickets
      unless ticket_ids.empty?
        destroy_tickets(ticket_ids)
      end
    end

    private

    STAFF_INBOX = 'staff.prison.visits'.freeze

    def ticket_ids
      ids = []
      @pool.with do |client|
        ids += client.search(old_tickets_query).map(&:id)
      end
      ids
    end

    def destroy_tickets(ids)
      @pool.with do |client|
        client.tickets.destroy_many(ids: ids, verb: :delete).fetch
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
  end
end
