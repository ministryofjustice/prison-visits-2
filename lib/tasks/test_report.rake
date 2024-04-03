namespace :reporting do
  desc 'Print monthly reporting figures'
  task monthly_reporting: :environment do
    start_date = '2024-03-01'
    yesterday_date = '2024-03-31'
    # start_date = 1.month.ago.to_date
    # yesterday_date = 1.day.ago.to_date
    prisons = Prison.where(enabled: true)
    prisons.each do |prison|
      puts prison.id
      puts prison.visits.where(processing_state: 'booked', created_at: start_date..yesterday_date).count  # Booked count
      puts prison.visits.where(processing_state: 'requested').count                                       # Requested count
      visits = prison.visits.where(created_at: start_date..yesterday_date, processing_state: 'rejected')
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
end
