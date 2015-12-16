FactoryGirl.define do
  factory :visitor do
    visit

    first_name do
      FFaker::Name.first_name
    end

    last_name do
      FFaker::Name.last_name
    end

    date_of_birth '1980-01-10'

    sort_index do |v|
      v.visit.visitors.count
    end
  end
end
