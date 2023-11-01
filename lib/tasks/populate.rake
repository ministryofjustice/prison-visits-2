namespace :pvb do
  namespace :populate do
    def generate_prisoner_number
      [
        ('A'..'Z').to_a.sample,
        Array.new(4) { (0..9).to_a.sample },
        Array.new(2) { ('A'..'Z').to_a.sample }
      ].join
    end

    def generate_first_name
      %w[Adalberto Franklyn Jaime Meghann Sally Tommie].sample
    end

    def generate_last_name
      %w[Wilderman Silverman Kennedy Loughran Marquet].sample
    end

    def generate_past_date
      (25..60).to_a.sample.years.ago + (1..20).to_a.sample.days
    end

    def generate_prisoner
      Prisoner.create(
        first_name: generate_first_name,
        last_name: generate_last_name,
        date_of_birth: generate_past_date,
        number: generate_prisoner_number
      )
    end

    def visitor_attributes
      {
        first_name: generate_first_name,
        last_name: generate_last_name,
        date_of_birth: generate_past_date
      }
    end

    def generate_visit(prison)
      slots = prison.available_slots.to_a.sample(3)
      visit = Visit.create!(
        prisoner: generate_prisoner,
        contact_phone_no: '07777777777',
        contact_email_address: "#{generate_last_name}@example.com",
        prison: prison,
        slot_option_0: slots.pop,
        slot_option_1: slots.pop,
        slot_option_2: slots.pop,
        locale: 'en',
        created_at: (1..20).to_a.sample.days.ago
      )
      HumanReadableId.update_unique_id(Visit, visit.id, :human_id)
      rand(1..5).times.map do |i|
        visit.visitors.create!(
          visitor_attributes.merge(sort_index: i)
        )
      end
      visit.visitors.create!(
        first_name: generate_first_name,
        last_name: generate_last_name,
        date_of_birth: (prison.adult_age - 1).years.ago,
        sort_index: visit.visitors.size + 1
      )
      visit
    end

    def fake_processing_time(visit)
      vsc = visit.visit_state_changes.order(created_at: :desc).first
      vsc.update!(created_at: visit.created_at + (1..6).to_a.sample.day)
    end

    def book(visit)
      granted_slot = [
        visit.slot_option_0, visit.slot_option_1, visit.slot_option_2
      ].sample

      closed = [true, false].sample
      visit.update!(
        slot_granted: granted_slot, reference_no: 'none', closed: closed)
      visit.accept!
      fake_processing_time(visit)
    end

    def reject_visit(visit, _num)
      attributes = if rand(10).even?
                     { rejection_attributes:
                         { reasons: [Rejection::REASONS.sample] }
                     }
                   else
                     {
                       rejection_attributes: {
                         reasons: [Rejection::REASONS.sample],
                         allowance_renews_on: (1..10).
                                              to_a.
                                              sample.
                                              days.
                                              from_now
                       }
                     }
                   end

      if attributes[:rejection_attributes][:reasons].
          include?(Rejection::OTHER_REJECTION_REASON)
        attributes[:rejection_attributes][:rejection_reason_detail] = "It's complicated"
      end

      visit.assign_attributes(attributes)

      BookingResponder::Reject.new(
        StaffResponse.new(visit: visit)
      ).process_request
      fake_processing_time(visit.reload)
    end

    def cancel_visit(visit, num)
      if num.even?
        CancellationResponse.new(
          visit, { reasons: [Cancellation::REASONS.sample] }
        ).cancel!
      else
        VisitorCancellationResponse.new(visit: visit).cancel!
      end
    end

    desc 'populate visits for review apps or dev environments'
    task visits: :environment do
      require 'human_readable_id'

      %w[Sudbury Pentonville Usk Aylesbury].each do |prison_name|
        prison = Prison.find_by!(name: prison_name)
        visits = 0.upto(ENV.fetch('COUNT', 14).to_i).map { |_i|
          visit = generate_visit(prison)
          visit.save!
          visit
        }

        _, withdrawn, booked, rejected, cancelled = visits.in_groups(5, false)

        withdrawn.each(&:withdraw!)

        booked.each do |visit|
          book(visit)
        end

        rejected.each_with_index do |visit, i|
          reject_visit(visit, i)
        end

        cancelled.each_with_index do |visit, i|
          book(visit) && cancel_visit(visit, i)
        end
      end
    end
  end
end
