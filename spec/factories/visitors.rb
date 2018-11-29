FactoryBot.define do
  factory :visitor do
    visit

    first_name do
      FFaker::Name.first_name
    end

    last_name do
      FFaker::Name.last_name
    end

    date_of_birth do '1980-01-10' end

    sort_index do |v|
      v.visit.visitors.count
    end

    trait :banned do
      banned { true }
    end

    trait :not_on_list do
      not_on_list { true }
    end
  end
end
