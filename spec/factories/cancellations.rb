FactoryBot.define do
  factory :cancellation do
    association :visit, processing_state: 'cancelled'
    reasons { ['prisoner_moved'] }
  end
end
