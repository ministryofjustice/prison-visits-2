namespace :zendesk do
  desc 'Delete zendesk tickets in staff inbox older than 12 months'
  task :cleanup  do
    ZendeskCleaner.new.delete_tickets
  end
end
