class ZendeskCleaner
  include ZendeskClient

  STAFF_INBOX = 'staff.prison.visits created'.freeze

  def delete_tickets
    ticket_id_batches.each do |id_batch|
      ZendeskAPI::Ticket.destroy_many!(client, ids: id_batch)
    end
  end

private

  def ticket_id_batches
    client.
      search(query: "type:ticket tags:#{STAFF_INBOX}<#{twelve_months_ago}").
      map(&:id).
      each_slice(100).
      to_a
  end

  def twelve_months_ago
    Time.zone.today.months_ago(12).strftime('%Y-%m-%d')
  end
end
