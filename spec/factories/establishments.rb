FactoryBot.define do
  factory :establishment, class: 'Nomis::Establishment' do
    skip_create
    initialize_with do new end

    code { 'BMI' }
  end
end
