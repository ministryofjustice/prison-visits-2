FactoryBot.define do
  factory :prisoner_not_found, class: 'Nomis::NullPrisoner' do
    skip_create
    initialize_with { new(id: nil, api_call_successful: true) }
  end
end
