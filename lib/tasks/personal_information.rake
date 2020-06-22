namespace :anonymise do
  desc 'Anonymise data that is at least 6 months old'
  task remove_old_personal_information: :environment do
    Rails.logger.info 'Beginning anonymising old data'
    cutoff = Time.zone.now - 6.months
    Depersonalizer.new.remove_personal_information cutoff
    Rails.logger.info 'Completed anonymising old data'
  end
end
