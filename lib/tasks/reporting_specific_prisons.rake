namespace :reporting do
  desc 'Visit reporting script'
  task visit_and_visitors: :environment do
    start = '2023-12-01'
    finish = '2024-02-29'
    prisonA = Prison.select(:id).where(name: 'Drake Hall')
    prisonB = Prison.select(:id).where(name: 'Foston Hall')
    visitIds = Visit.where(prison_id: prisonA, processing_state: 'booked', created_at: start..finish).pluck(:id)
    visitIds.each do |vId|
      prisoner = Visit.where(id: vid).pluck(:prisoner_id)
      puts Visit.select(:prison_id, :id, :contact_email_address, :contact_phone_no, :prisoner_id).where(id: vid)
      puts Prisoner.select(:id, :nomis_offender_id)
      puts Visitor.select(:visit_id, :first_name, :last_name).where(visit_id: vid)
    end
  end
end
