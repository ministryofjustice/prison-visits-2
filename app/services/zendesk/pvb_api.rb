module Zendesk
  class PvbApi
    def initialize(zendesk_client)
      @client = zendesk_client
    end

    def raise_ticket(ticket_attrs)
      ZendeskAPI::Ticket.create!(@client, ticket_attrs)
    end

    def cleanup_tickets
      unless ticket_ids.empty?
        destroy_tickets(ticket_ids)
      end
    end

  private

    STAFF_INBOX = 'staff.prison.visits'.freeze

    def ticket_ids
      @client.search(old_tickets_query).map(&:id)
    end

    def destroy_tickets(ids)
      @client.tickets.destroy_many(ids: ids, verb: :delete).fetch
    end

    def twelve_months_ago
      Time.zone.today.months_ago(12).strftime('%Y-%m-%d')
    end

    def old_tickets_query
      {
        query: "type:ticket tags:#{STAFF_INBOX} updated<#{twelve_months_ago}",
        reload: true
      }
    end
  end
end
