# frozen_string_literal: true
FactoryGirl.define do
  factory :prison do
    estate

    name do |p|
      "#{p.estate.name} Open Prison"
    end

    enabled true

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
      10 + rand(9)
    end

    slot_details 'recurring' => {
      'mon' => ['1400-1610'],
      'tue' => ['0900-1000', '1400-1610']
    }
  end
end
