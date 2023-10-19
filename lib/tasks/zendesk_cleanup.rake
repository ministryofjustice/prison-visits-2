namespace :zendesk do
  desc 'Delete zendesk tickets that have not been updated in twelve months'
  task cleanup: :environment do
    client = Zendesk::PVBClient.instance
    staff_inbox = 'staff.prison.visits'.freeze
    public_inbox = 'prison_visits'.freeze

    [staff_inbox, public_inbox].each do |inbox|
      Rails.logger.info "Beginning Zendesk clean up task for inbox #{inbox}"
      Zendesk::PVBApi.new(client).cleanup_tickets(inbox)
      Rails.logger.info "Completed Zendesk clean up task for inbox #{inbox}"
    end
  end
end
