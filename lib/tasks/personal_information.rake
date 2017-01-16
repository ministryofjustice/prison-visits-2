# frozen_string_literal: true
task remove_old_personal_information: :environment do
  cutoff = Time.zone.now - 1.month
  Depersonalizer.new.remove_personal_information cutoff
end
