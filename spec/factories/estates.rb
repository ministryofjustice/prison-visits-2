FactoryGirl.define do
  factory :estate do
    name do
      FFaker::AddressUK.city
    end
  end
end
