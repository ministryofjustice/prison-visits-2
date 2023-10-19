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
      sprintf('01154960%03d', n)
    end

    adult_age do
      rand(10..19)
    end

    slot_details {
      { 'recurring' => {
        'mon' => ['1400-1610'],
        'tue' => %w[0900-1000 1400-1610]
      } }
    }
  end
end
