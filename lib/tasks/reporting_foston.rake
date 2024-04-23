namespace :reporting do
  desc 'Visit reporting script'
  task foston_hall: :environment do
    start = '2024-01-01'
    finish = '2024-02-29'
    prison_code = Prison.select(:id).where(name: 'Foston Hall')
    puts 'foston hall'
    visit_ids = Visit.where(prison_id: prison_code, processing_state: 'booked', created_at: start..finish).pluck(:id)
    visit_ids.each do |vid|
      prisoner_id = Visit.where(id: vid).pluck(:prisoner_id)
      puts Visit.select(:contact_email_address, :contact_phone_no).where(id: vid)
      puts Prisoner.select(:nomis_offender_id).where(id: prisoner_id)
      puts Visitor.select(:first_name, :last_name).where(visit_id: vid)
    end
  end
end
