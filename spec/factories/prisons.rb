FactoryGirl.define do
  factory :prison do
    name do |p|
      "#{p.estate} Open Prison"
    end

    sequence :nomis_id do |n|
      ('%03d' % n).tr('0123456789', 'ABCDEFGHIJ')
    end

    enabled true

    estate do
      FFaker::AddressUK.city
    end

    address do
      FFaker::AddressUK.street_address
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

    slot_details recurring: {
      mon: ['1400-1610'],
      tue: ['0900-1000', '1400-1610']
    }
  end
end
