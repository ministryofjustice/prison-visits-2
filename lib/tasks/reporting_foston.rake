namespace :reporting do
  desc 'Visit reporting script'
  task foston_hall: :environment do
    # 28th May until 24th June
    start = '2024-05-28'
    finish = '2024-06-24'
    prison_code = Prison.select(:id).where(name: 'Foston Hall')
    visit_ids = Visit.where(prison_id: prison_code, processing_state: 'booked', created_at: start..finish).pluck(:id)
    visit_ids.each do |vid|
      prisoner_id = Visit.where(id: vid).pluck(:prisoner_id)
      selected_visit = Visit.where(id: vid)
      prisoner = Prisoner.where(id: prisoner_id)
      visitors = Visitor.where(visit_id: vid)
      text_line = "#{selected_visit[0].contact_email_address}, #{selected_visit[0].contact_phone_no}, #{prisoner[0].first_name} #{prisoner[0].last_name}, #{prisoner[0].number},"
      visitors.each do |visitor|
        text_line += "#{visitor.first_name} #{visitor.last_name},"
      end
      puts text_line
    end
  end
end
