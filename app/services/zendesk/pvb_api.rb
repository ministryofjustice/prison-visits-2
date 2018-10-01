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

    def cleanup_tickets(inbox)
      # rubocop:disable Lint/AssignmentInCondition
      until (ids = fetch_ticket_ids(inbox)) && ids.empty?
        destroy_tickets(ids)
      end
      # rubocop:enable Lint/AssignmentInCondition
    end

  private

    attr_accessor :zendesk_pvb_client

    def fetch_ticket_ids(inbox)
      request { |client| client.search(old_tickets_query_for(inbox)).map(&:id) }
    end

    def destroy_tickets(ids)
      request do |client|
        ZendeskAPI::Ticket.destroy_many!(client, ids)
      end
    end

    def twelve_months_ago
      12.months.ago.strftime('%Y-%m-%d')
    end

    def old_tickets_query_for(inbox)
      {
        query: "type:ticket tags:#{inbox} updated<#{twelve_months_ago}",
        reload: true
      }
    end

    def request(&block)
      zendesk_pvb_client.request(&block)
    end
  end
end
