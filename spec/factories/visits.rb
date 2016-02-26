FactoryGirl.define do
  factory :visit do
    prison
    prisoner

    contact_email_address do
      FFaker::Internet.disposable_email
    end

    contact_phone_no do
      FFaker::PhoneNumber.short_phone_number
    end

    slot_option_0 do |v|
      v.prison.available_slots.first
    end

    locale 'en'

    after(:create) do |v|
      create :visitor, visit: v
    end

    factory :visit_with_two_visitors do
      after(:create) do |v|
        create :visitor, visit: v
      end
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
      processing_state 'booked'

      slot_granted do |v|
        v.slot_option_0
      end

      sequence :reference_no do |n|
        '%08d' % n
      end
    end

    factory :cancelled_visit do
      processing_state 'cancelled'
    end

    factory :rejected_visit do
      processing_state 'rejected'
    end

    factory :withdrawn_visit do
      processing_state 'withdrawn'
    end
  end
end
