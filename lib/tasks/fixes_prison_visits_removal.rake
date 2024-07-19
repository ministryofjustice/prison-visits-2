namespace :fixes do
  desc 'Visit requested removal'
  task prison_visits_removal: :environment do
    # Change prison name
    prison_name = 'Pentonville'
    selected_prison = Prison.where(name: prison_name)
    # Only targets requested visits for the named prison
    selected_visits = Visit.where(prison_id: selected_prison.first.id, processing_state: 'requested') 
    selected_visits.each do |visit|
      visit.processing_state = 'withdrawn'
      visit.save
    end
  end
end
