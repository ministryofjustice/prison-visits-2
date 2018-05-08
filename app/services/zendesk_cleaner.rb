class ZendeskCleaner
  STAFF_INBOX = "staff.prison.visits created".freeze

  def delete_tickets
    unless Rails.configuration.try(:zendesk_client)
      fail 'Cannot delete Zendesk tickets as Zendesk is not configured'
    end

    client = Rails.configuration.zendesk_client
    ticket_ids = client.
      search(query: "type:ticket tags:#{STAFF_INBOX}<#{twelve_months_ago}").
      map {|ticket| ticket[:id] }

    ticket_ids.each_slice(100).to_a.each do |id_batch|
      ZendeskAPI::Ticket.destroy_many!(client, ids: id_batch)
    end
  end

  private

  def twelve_months_ago
    Date.today.months_ago(12).strftime("%Y-%m-%d")
  end
end
