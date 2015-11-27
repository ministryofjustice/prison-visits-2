FactoryGirl.define do
  factory :visit do
    prison

    prisoner_first_name do
      FFaker::Name.first_name
    end

    prisoner_last_name do
      FFaker::Name.last_name
    end

    prisoner_date_of_birth '1970-01-01'
    sequence(:prisoner_number) do |n|
      'ABC%04d' % n
    end

    visitor_first_name do
      FFaker::Name.first_name
    end

    visitor_last_name do
      FFaker::Name.last_name
    end

    visitor_date_of_birth '1980-01-10'

    contact_email_address do
      FFaker::Internet.disposable_email
    end

    contact_phone_no do
      FFaker::PhoneNumber.short_phone_number
    end

    slot_option_0 do |v|
      v.prison.available_slots.first
    end

    factory :visit_with_three_slots do
      slot_option_1 do |v|
        v.prison.available_slots.to_a[1]
      end

      slot_option_2 do |v|
        v.prison.available_slots.to_a[2]
      end
    end

    factory :booked_visit do
      slot_granted do |v|
        v.slot_option_0
      end

      sequence :reference_no do |n|
        '%08d' % n
      end

      processing_state 'booked'
    end

    factory :rejected_visit do
      processing_state 'rejected'
    end
  end
end
