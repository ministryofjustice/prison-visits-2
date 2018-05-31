namespace :zendesk do
  desc 'Delete zendesk tickets in staff inbox that have not been updated in twelve month'
  task cleanup: :environment do
    client_pool = Zendesk::Client.instance.pool
    Zendesk::PVBApi.new(client_pool).cleanup_tickets
  end
end
