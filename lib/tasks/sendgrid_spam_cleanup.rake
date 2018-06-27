namespace :sendgrid do
  desc 'Delete zendesk tickets in staff inbox that have not been updated in twelve months'
  task delete_spam_list: :environment do
    Rails.logger.info 'Requesting deletion of spam list on Sendgrid'
    SendgridApi.instance.delete_spam_list
  end
end
