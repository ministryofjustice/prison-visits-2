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
      puts ''
    end
  end

  desc 'staff_messages_to_visitors'
  # Return all custom messages sent by staff to visitors
  # Has a minimum character limit as we're looking to remove message that just include reference
  # Has a specific date range, as the data returned is large for even a 1 month period
  # Prints into format:
  # Message, prison name, date of messages
  task staff_messages: :environment do
    start_date = '2024-11-01'
    end_date = '2024-11-05'
    messages = Message.where(created_at: start_date..end_date)
    messages.each do |message|
      next unless message.body.length > 100 # Only print for messages above this length

      prison_id = Visit.where(id: message.visit_id).pluck(:prison_id)

      message_body = message.body.remove("\n", "\r", "\t", ';', '•', ',') # Remove all additional formatting added by staff
      prison = Prison.where(id: prison_id)
      message_date = message.created_at

      puts "#{message_body}, #{prison[0].name}, #{message_date}"
    end
  end

  desc 'Prisoner name / number, as entered by the visitor'
  task prisoner_name_and_number: :environment do
    start_date = '2024-09-01'
    end_date = '2024-11-01'
    prisoners = Prisoner.where(created_at: start_date..end_date).order(created_at: :desc)
    prisoners.each do |prisoner|
      text_line = "#{prisoner.first_name}, #{prisoner.last_name}, #{prisoner.number}"
      puts text_line
    end
  end
end
