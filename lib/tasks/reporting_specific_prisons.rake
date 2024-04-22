namespace :reporting do
  desc 'Visit reporting script'
  task visit_and_visitors: :environment do
    start = '2024-01-01'
    finish = '2024-02-29'
    prison_code = Prison.select(:id).where(name: 'Drake Hall')
    # prison_code = Prison.select(:id).where(name: 'Foston Hall')
    puts 'drake hall'
    visit_ids = Visit.where(prison_id: prison_code, processing_state: 'booked', created_at: start..finish).pluck(:id)
    visit_ids.each do |vid|
      Visit.where(id: vid).pluck(:prisoner_id)
      puts Visit.select(:prison_id, :id, :contact_email_address, :contact_phone_no, :prisoner_id).where(id: vid)
      puts Prisoner.select(:id, :nomis_offender_id)
      puts Visitor.select(:visit_id, :first_name, :last_name).where(visit_id: vid)
    end
  end
end
