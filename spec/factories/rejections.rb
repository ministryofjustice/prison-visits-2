FactoryGirl.define do
  factory :rejection do
    association :visit, processing_state: 'rejected'
    reason 'no_allowance'
  end
end
