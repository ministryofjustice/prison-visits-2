namespace :sendgrid do
  desc 'Deletes the spam list on Sendgrid'
  task delete_spam_list: :environment do
    Rails.logger.info 'Requesting deletion of spam list on Sendgrid'
    SendgridApi.instance.delete_spam_list
  end
end
