namespace :zendesk do
  desc 'Delete zendesk tickets in staff inbox that have not been updated in twelve months'
  task cleanup: :environment do
    client = Zendesk::PVBClient.instance
    Rails.logger.info 'Beginning Zendesk clean up task'
    Zendesk::PVBApi.new(client).cleanup_tickets
    Rails.logger.info 'Completed Zendesk clean up task'
  end
end
