task remove_old_personal_information: :environment do
  cutoff = Time.zone.now - 6.months
  Depersonalizer.new.remove_personal_information cutoff
end
