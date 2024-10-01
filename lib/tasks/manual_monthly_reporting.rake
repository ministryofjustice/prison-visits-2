namespace :manual_monthly_reporting do
  start_date = '2024-09-01'
  end_date = '2024-09-30'
  desc 'Print monthly reporting figures'
  # List each prisons booked requested rejected and then cancelled reasons
  task prison_stats: :environment do
    prisons = Prison.where(enabled: true)
    prisons.each do |prison|
      puts prison.id
      puts prison.visits.where(processing_state: 'booked', created_at: start_date..end_date).count  # Booked count
      puts prison.visits.where(processing_state: 'requested').count                                       # Requested count
      visits = prison.visits.where(created_at: start_date..end_date, processing_state: 'rejected')
      rejections = Rejection.where(visit: visits)
      puts rejections.count                                                                               # Rejections count
      puts rejections.count{ |s| s.reasons.include?('slot_unavailable') }
      puts rejections.count{ |s| s.reasons.include?('visitor_not_on_list') }
      puts rejections.count{ |s| s.reasons.include?('visitor_banned') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_out_of_prison') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_banned') }
      puts rejections.count{ |s| s.reasons.include?('duplicate_visit_request') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_released') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_moved') }
      puts rejections.count{ |s| s.reasons.include?('child_protection_issues') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_non_association') }
      puts rejections.count{ |s| s.reasons.include?('prisoner_details_incorrect') }
      puts rejections.count{ |s| s.reasons.include?('no_adult') }
      puts rejections.count{ |s| s.reasons.include?('no_allowance') }
      puts prison.visits.where(processing_state: 'requested').order(created_at: :asc).limit(1).pluck(:created_at) # Oldest request
      puts 'end'
    end
  end
  desc 'Visit processing times (monthly)'
  # List processing times for each visits with a booker and rejected state
  task processing_times: :environment do
    prisons = Prison.where(enabled: true)
    prisons.each do |prison|
      selected_visits = Visit.where(created_at: start_date..end_date, prison_id: prison.id, processing_state: ['booked', 'rejected']).order(created_at: :desc)
      selected_visits.each do |visit|
        text_line = "#{prison.name}, #{visit.processing_state}, #{visit.created_at}, #{visit.updated_at}"
        puts text_line
      end
    end
  end
  desc 'Foston Hall users (monthly)'
  # List all users for named prison - onboarding
  task foston_hall: :environment do
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
