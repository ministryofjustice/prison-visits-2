FactoryBot.define do
  factory :offender_not_found, class: Nomis::NullOffender do
    skip_create
    initialize_with { new(id: nil, api_call_successful: true) }
  end
end
