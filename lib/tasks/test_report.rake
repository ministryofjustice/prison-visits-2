namespace :reporting do
  desc 'Print monthly reporting figures'
  task monthly_reporting: :environment do
    start = 'november 01 2023'
    today = 'november 30 2023'
    pid = '0e034353-5939-467e-b618-5e5b81a4a2a2'
    puts Visit.where(prison_id: pid, processing_state: 'booked').where({ created_at: Date.parse(start)..Date.parse(today) }).count
    puts Visit.select(:created_at).where(prison_id: pid, processing_state: 'booked').order(created_at: :desc).limit(1)
    puts Visit.where(prison_id: pid, processing_state: 'requested').count
    puts Visit.select(:created_at).where(prison_id: pid, processing_state: 'requested').order(created_at: :asc).limit(1)
    puts Visit.select(:created_at).where(prison_id: pid, processing_state: 'requested').order(created_at: :desc).limit(1)
    ids = Visit.where(prison_id: pid).where({ created_at: Date.parse(start)..Date.parse(today) }).where(processing_state: 'rejected').pluck(:id)
    rejections = Rejection.where(visit_id: ids)
    puts rejections.count
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
    puts 'split'
  end
end
