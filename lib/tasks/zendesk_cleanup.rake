namespace :zendesk do
  desc 'Delete zendesk tickets in staff inbox that have not been updated in twelve month'
  task cleanup: :environment do
    client = Zendesk::Client.instance
    Zendesk::PvbApi.new(client).cleanup_tickets
  end
end
