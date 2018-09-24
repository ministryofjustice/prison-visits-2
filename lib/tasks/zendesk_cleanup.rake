namespace :zendesk do
  desc 'Delete zendesk tickets that have not been updated in twelve months'
  task cleanup: :environment do
    client = Zendesk::PVBClient.instance
    STAFF_INBOX = 'staff.prison.visits'.freeze
    PUBLIC_INBOX = 'prison_visits'.freeze

    [STAFF_INBOX, PUBLIC_INBOX].each do |inbox|
      Rails.logger.info "Beginning Zendesk clean up task for inbox #{inbox}"
      Zendesk::PVBApi.new(client).cleanup_tickets(inbox)
      Rails.logger.info "Completed Zendesk clean up task for inbox #{inbox}"
    end
  end
end
