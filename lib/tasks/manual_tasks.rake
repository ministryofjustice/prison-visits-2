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
end
