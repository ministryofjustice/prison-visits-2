namespace :anonymise do
  desc 'Anonymise data that is at least 6 months old'
  task remove_old_personal_information: :environment do
    cutoff = Time.zone.now - 6.months
    Depersonalizer.new.remove_personal_information cutoff
  end
end
