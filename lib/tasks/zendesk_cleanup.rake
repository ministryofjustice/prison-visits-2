namespace :zendesk do
  desc 'Delete zendesk tickets in staff inbox that have not been updated in twelve month'
  task cleanup: :environment do
    client = Zendesk::PVBClient.instance
    Zendesk::PVBApi.new(client).cleanup_tickets
  end
end
