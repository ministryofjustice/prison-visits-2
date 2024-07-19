namespace :fixes do
  desc 'Visit requested removal'
  task prison_visits_removal: :environment do
    # Change prison name
    prison_name = 'Pentonville'
    selectedPrison = Prison.where(name: prison_name)
    # Only targets requested visits for the named prison
    selectedVisits = Visit.where(prison_id: selectedPrison.first.id, processing_state: 'requested') 
    selectedVisits.each do |visit|
      visit.processing_state = 'withdrawn'
      visit.save
    end
  end
end
