namespace :manual_tasks do
  desc 'Visit requested removal'
  # Remove all requested visits from named prison - onboarding
  task prison_visits_removal: :environment do
    prison_name = 'Pentonville'
    selected_prison = Prison.where(name: prison_name)
    selected_visits = Visit.where(prison_id: selected_prison.first.id, processing_state: 'requested')
    selected_visits.each do |visit|
      visit.processing_state = 'withdrawn'
      visit.save
    end
  end
  desc 'visitors_and_dates_for_email'
  # Return last 20 visits requested by XXX email address
  # Requests older than 6 months will already be anonymised
  # Prints into format: 
  # state, created at, accepted slot
  # requested slots
  # visitors
  task visitors_and_dates_for_email: :environment do
    visits = Visit.where(contact_email_address: 'XXX').order(created_at: :desc).limit(20)
    visits.each do |visit|
    text_line = ''
      puts "state: #{visit.processing_state}  /  created at: #{visit.created_at}  /  accepted slot: #{visit.slot_granted}"
      puts "requested slots: #{visit.slot_option_0}  /  #{visit.slot_option_1}  /  #{visit.slot_option_2}"
      visitors = Visitor.where(visit_id: visit.id)
      visitors.each do |visitor|
        text_line += "#{visitor.first_name} #{visitor.last_name} - "
      end
      puts text_line
      puts " "
    end
  end
end
