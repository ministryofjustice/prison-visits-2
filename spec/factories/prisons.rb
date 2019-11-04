FactoryBot.define do
  factory :prison do
    estate

    name do |p|
      "#{p.estate.name} Open Prison"
    end

    enabled do true end

    address do
      FFaker::AddressUK.street_address
    end

    postcode do
      FFaker::AddressUK.postcode
    end

    email_address do
      FFaker::Internet.disposable_email
    end

    sequence :phone_no do |n|
      '01154960%03d' % n
    end

    adult_age do
      rand(10..19)
    end

    slot_details do { 'anomalous' => [] } end

    factory :prison_with_slots do
      slot_days {
        [
          build(:slot_day, day: 'mon', slot_times: [
            build(:slot_time, begin_hour: 14, begin_minute: 0, end_hour: 16, end_minute: 10)
          ]),
          build(:slot_day, day: 'tue', slot_times: [
            build(:slot_time, begin_hour: 9, begin_minute: 0, end_hour: 10, end_minute: 0),
            build(:slot_time, begin_hour: 14, begin_minute: 0, end_hour: 16, end_minute: 10)
          ])
        ]
      }
    end
  end

  factory :slot_day do
    association :prison

    start_date do Date.new(2010, 1, 1) end
    day { 'mon' }
  end

  factory :slot_time do
    association :slot_day

    begin_hour do 0 end
    begin_minute do 0 end
    end_hour do 23 end
    end_minute { 59 }
  end

  factory :unbookable_date do
    association :prison

    sequence(:date) { |n| Time.zone.today + n.days }
  end
end
