namespace :pvb do
  desc 'load the backup nomis slots from NOMIS API'
  task load_nomis_slots: :environment do
    Prison.where(name: Rails.configuration.public_prisons_with_slot_availability).find_each do |prison|
      prison.nomis_concrete_slots.clear
      ApiSlotAvailability.new(prison:, use_nomis_slots: true).slots.each do |slot|
        prison.nomis_concrete_slots.create!(date: slot.to_date,
                                            start_hour: slot.begin_hour,
                                            start_minute: slot.begin_minute,
                                            end_hour: slot.end_hour,
                                            end_minute: slot.end_minute)
      end
    end
  end
end
