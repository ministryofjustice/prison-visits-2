FactoryBot.define do
  factory :visit do
    association :prison, factory: :prison_with_slots
    prisoner

    contact_email_address do
      FFaker::Internet.disposable_email
    end

    contact_phone_no do '07900112233' end

    sequence :human_id do |n|
      'VISIT' + ('%03d' % n)
    end

    slot_option_0 do |v|
      v.prison.available_slots.first
    end

    locale do 'en' end

    after(:create) do |v|
      create :visitor, visit: v
    end

    trait :requested do
      processing_state { 'requested' }
    end

    trait :booked do
      processing_state { 'booked' }
    end

    trait :nomis_cancelled do
      processing_state do 'cancelled' end

      after(:create) do |v|
        create :cancellation, visit: v, nomis_cancelled: true
      end
    end

    trait :pending_nomis_cancellation do
      processing_state do 'cancelled' end

      after(:create) do |v|
        create :cancellation, visit: v, nomis_cancelled: false
      end
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
      processing_state do 'booked' end

      slot_granted do |v|
        v.slot_option_0
      end

      sequence :reference_no do |n|
        '%08d' % n
      end
    end

    factory :cancelled_visit do
      processing_state do 'cancelled' end

      slot_granted do |v|
        v.slot_option_0
      end
    end

    factory :rejected_visit do
      rejection_attributes do { reasons: [Rejection::SLOT_UNAVAILABLE] } end
      after :create do |visit|
        BookingResponder.new(StaffResponse.new(visit: visit)).respond!
      end
    end

    factory :withdrawn_visit do
      processing_state { 'withdrawn' }
    end
  end
end
