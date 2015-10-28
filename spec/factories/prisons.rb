FactoryGirl.define do
  factory :prison do
    name 'Reading Gaol'
    nomis_id 'XYZ'
    enabled true
    estate 'Reading'
    address '1 High Street'
    email_address 'reading.gaol@test.example.com'
    phone_no '01154960123'
    slot_details recurring: {
      mon: ['1400-1610'],
      tue: ['0900-1000', '1400-1610']
    }
  end
end
